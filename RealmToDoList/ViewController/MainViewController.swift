import UIKit
import RealmSwift

final class MainViewController: UIViewController {
    
    // MARK: - UI
    private let mainTableView = UITableView()
    private var addTaskButton: UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createAlert))
        return button
    }
    
    // MARK: - Realm
    private let realm = try! Realm(configuration: .defaultConfiguration)
    private var notificationToken: NotificationToken? = nil
    
    // MARK: - VC Lifesycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "To Do List"
        configureMainTableView()
        configureAddTaskButton()
        configureRealm()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setConstraintsForTableView()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    @objc func createAlert() {
        let alertController = UIAlertController(title: "Creating task", message: "Fill task name", preferredStyle: .alert)
        alertController.addTextField()
        let alertAddAction = UIAlertAction(title: "Add task", style: .default) { [weak self] _ in
            guard let textFieldText = alertController.textFields?.first?.text, !textFieldText.isEmpty else { return }
            guard let self = self else { return }
            
            let task = Task()
            task.taskName = textFieldText
            task.isCompleted = false
            
            try! self.realm.write {
                self.realm.add(task)
            }
            
        }
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(alertCancelAction)
        alertController.addAction(alertAddAction)
        self.present(alertController, animated: true)
    }
    
    // MARK: - RealmConfiguring
    
    func configureRealm() {
        
        let loadedTasks = realm.objects(Task.self)
        notificationToken = loadedTasks.observe { [weak self] (result) in
            guard let tableView = self?.mainTableView else { return }
            
            switch result {
            case .initial:
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .fade)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .fade)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .fade)
                tableView.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    // MARK: - Config
    private func configureAddTaskButton() {
        navigationItem.rightBarButtonItem = addTaskButton
    }
    
    private func configureMainTableView() {
        view.addSubview(mainTableView)
        mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.mainCellId)
        mainTableView.dataSource = self
    }
    
    private func setConstraintsForTableView() {
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        mainTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mainTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mainTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tasks = realm.objects(Task.self)
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: Constants.mainCellId, for: indexPath)
        let tasks = Array(realm.objects(Task.self))
        cell.textLabel?.text = tasks[indexPath.row].taskName
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let tasks = Array(realm.objects(Task.self))
            let currentTask = tasks[indexPath.row]
            try! realm.write {
                realm.delete(currentTask)
            }
        }
    }
    
}

