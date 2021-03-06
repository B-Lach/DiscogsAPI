// DGArtistViewController.swift
//
// Copyright (c) 2017 Maxime Epain
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import DiscogsAPI

class DGArtistViewController: DGViewController {
    
    fileprivate var response : DGArtistReleasesResponse! {
        didSet { tableView.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get artist details
        Discogs.api.database.get(artist: objectID, success: { (artist) in
            
            self.titleLabel.text    = artist.name
            self.styleLabel.text    = artist.profile
            
            if let members = artist.members {
                self.detailLabel.text = self.membersAsString(members)
            }
            
            // Get a Discogs image
            if let image = artist.images?.first, let url = image.resourceURL {
                Discogs.api.resource.get(image: url, success: { (image) in
                    self.coverView?.image = image
                })
            }
            
        }) { (error) in
            print(error)
        }

        // Get artist release
        let request = DGArtistReleasesRequest()
        request.artistID = objectID
        request.pagination.perPage = 25
        
        Discogs.api.database.get(request, success: { (response) in
            self.response = response
        }) { (error) in
            print(error)
        }
    }
    
    func membersAsString(_ members: [DGMember]!) -> String {
        var names = [String]()
        for member in members {
            names.append(member.name!)
        }
        return names.joined(separator: ", ")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = tableView.indexPathForSelectedRow, let destination = segue.destination as? DGViewController {
            destination.objectID = response.releases[indexPath.row].id
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return response?.releases.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Releases"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let release = response.releases[indexPath.row]
        let cell = dequeueReusableCellWithResult(release)
        
        cell.textLabel?.text       = release.title
        cell.detailTextLabel?.text = release.year?.stringValue
        cell.imageView?.image      = UIImage(named: "default-release")
        
        // Get a Discogs image
        if let thumb = release.thumb {
            Discogs.api.resource.get(image: thumb, success: { (image) in
                cell.imageView?.image = image
            })
        }
        
        // Load the next response page
        if release === response.releases.last {
            response.loadNextPage(success: {
                self.tableView.reloadData()
            })
        }
        
        return cell
    }
    
    func dequeueReusableCellWithResult(_ release : DGArtistRelease) -> UITableViewCell {
        if  release.type == "master" {
            return tableView.dequeueReusableCell(withIdentifier: "MasterCell")!
        }
        return tableView.dequeueReusableCell(withIdentifier: "ReleaseCell")!
    }
}
