//
//  FriendsListViewController.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/9/24.
//

import UIKit


class FriendListViewController: UITableViewController {
    var friends: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FriendCell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        let friend = friends[indexPath.row]
        cell.textLabel?.text = friend.username
        // Optionally load the profile image for each friend if you want
        return cell
    }
}
