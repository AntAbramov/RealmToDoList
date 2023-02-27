import UIKit
import RealmSwift

final class MainViewController: UIViewController {
    
    // MARK: - UI
    private let mainTableView = UITableView()
    private var addTaskButton: UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createAlert))
        return button
    }
    
    // MARK: - DataSource
    private var tasksDataSource: [String] = []
    
    // MARK: - VC Lifesycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMainTableView()
        configureAddTaskButton()
        tasksDataSource.append("Hello")
        title = "To Do List"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setConstraintsForTableView()
    }
    
    @objc func createAlert() {
        let alertController = UIAlertController(title: "Creating task", message: "Fill task name", preferredStyle: .alert)
        alertController.addTextField()
        let alertAddAction = UIAlertAction(title: "Add task", style: .default) { [weak self] _ in
            guard let textFieldText = alertController.textFields?.first?.text, !textFieldText.isEmpty else { return }
            guard let self = self else { return }
            
            self.tasksDataSource.append(textFieldText)
            let indexPath = IndexPath(row: self.tasksDataSource.count - 1, section: 0)
            self.mainTableView.insertRows(at: [indexPath], with: .fade)
        }
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(alertCancelAction)
        alertController.addAction(alertAddAction)
        self.present(alertController, animated: true)
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
        tasksDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: Constants.mainCellId, for: indexPath)
        cell.textLabel?.text = tasksDataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasksDataSource.remove(at: indexPath.row)
            mainTableView.deleteRows(at: [indexPath], with: .top)
        }
    }
    
}

