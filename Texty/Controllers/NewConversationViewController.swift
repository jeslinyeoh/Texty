//
//  NewConversationViewController.swift
//  Texty
//
//  Created by Jeslin Yeoh on 25/12/2021
//  following iOS Academy's YouTube tutorial..
//

import UIKit
import JGProgressHUD
import AVFoundation

final class NewConversationViewController: UIViewController {

    
    // closure which takes in dictionary and return void
    public var completion: ((SearchResult) -> (Void))?
    
    private let spinner = JGProgressHUD()
    
    private var users = [[String: String]]() // array of dictionaries, key and values are both strings
    private var results = [SearchResult]() // array of user's query results
    private var hasFetched = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    } ()
    
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationCell.self,
                       forCellReuseIdentifier: NewConversationCell.identifier)
        
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder() //invoke keyboard
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    

}


extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = results[indexPath.row] // nth position in the collection of results
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier, for: indexPath) as! NewConversationCell
        
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // start conversation
        let targetUserData = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 90
    }
    
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // make sure that the search bar is not empty including empty space
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        
        searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        // check if array has firebase results
        
        // if it does, filter
        if hasFetched {
            filterUsers(with: query)
        }
        
        
        // else, fetch then filter
        else {
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case.success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                    
    
                case.failure(let error):
                    print("Failed to get users: \(error)")
                }
                
                
            })
        }
        
    }
    
    
    func filterUsers(with term: String) {
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
             return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        spinner.dismiss()

        let results: [SearchResult] = users.filter({
            
            // don't show current user
            guard let email = $0["email"] as? String,
                  email != safeEmail else {
                      return false
                  }
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            
            return name.hasPrefix(term.lowercased())
            
        }).compactMap({
            
            // don't show current user
            guard let email = $0["email"],
                  let name = $0["name"] else {
                      return nil
                  }
            
            return SearchResult(name: name, email: email)
        })
        
        self.results = results
        
        updateUI()
        
    }
    
    func updateUI() {
        if results.isEmpty{
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        }
        
        else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}



