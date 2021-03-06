import UIKit
import DATAStack
import CoreData

class ViewController: UITableViewController {
    static let CellIdentifier = "CellID"
    unowned var dataStack: DATAStack
    lazy var networking: Networking = Networking(dataStack: self.dataStack)
    var items = [Data]()

    required init(dataStack: DATAStack) {
        self.dataStack = dataStack
        super.init(nibName: nil, bundle: nil);
    }

    required init!(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "AppNet"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.CellIdentifier)

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(ViewController.fetchNewData), for: .valueChanged)

        self.fetchCurrentObjects()
        self.fetchNewData()
    }

    func fetchNewData() {
        // Use the `networking.fetchLocalItems` method to try Sync's change notifications
        self.networking.fetchItems { _ in
            self.fetchCurrentObjects()
            self.refreshControl?.endRefreshing()
        }
    }

    func fetchCurrentObjects() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        self.items = (try! dataStack.mainContext.fetch(request)) as! [Data]
        self.tableView.reloadData()
    }
}

// MARK: UITableViewDataSource
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.CellIdentifier)
        let data = self.items[indexPath.row]
        cell?.textLabel?.text = data.text
        cell?.detailTextLabel?.text = data.user.username

        return cell!
    }
}
