//
//  CreateGroupViewController.swift
//  Gourmate-iOS
//
//  Created by Sriram Hariharan on 7/5/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AVFoundation

// Cell in Dietary Restriction table
class MateCell : UITableViewCell {
    @IBOutlet weak var mateImage: UIImageView!
    @IBOutlet weak var mateName: UILabel!
}

class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive: Bool = false
    @IBOutlet weak var allMatesTable: UITableView!
    @IBOutlet weak var selectedMatesTable: UITableView!
    @IBOutlet weak var matesLabel: UILabel!
    var mates:[MateObject] = []
    var filtered:[MateObject] = []
    var selected:[MateObject] = []
    var ref: DatabaseReference!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isLookingForQR = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allMatesTable.delegate = self
        allMatesTable.dataSource = self
        selectedMatesTable.delegate = self
        selectedMatesTable.dataSource = self
        searchBar.delegate = self
        ref = Database.database().reference()
        self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for child in snapshots {
                    if let mate = child.value as? NSDictionary {
                        self.mates.append(MateObject(mateObj: mate))
                        if curUserEmail == mate["email"] as? String {
                            self.selected.append(MateObject(mateObj: mate))
                        }
                    }
                    self.filtered = self.mates
                }
                self.allMatesTable.reloadData()
                self.selectedMatesTable.reloadData()

            }
        })
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    @IBAction func qrCodeButton(_ sender: Any) {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        var backbutton = UIButton(type: .custom)
        backbutton.setTitle("Cancel", for: .normal)
        backbutton.setTitleColor(backbutton.tintColor, for: .normal) // You can change the TitleColor
        backbutton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
        captureSession.startRunning()
    }
    
    @objc func buttonAction() -> Void {
        previewLayer.removeFromSuperlayer()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        previewLayer.removeFromSuperlayer()
    }
    
    func found(code: String) {
        print(code)
        if let mate = self.mates.first(where: {$0.email == code}){
            print(mate)
            let ac = UIAlertController(title: "Add Mate", message: "Found mate with email \(code)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.addMate(mate:mate)
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            present(ac, animated: true)
        } else {
            print("not valid")
            let ac = UIAlertController(title: "Not Valid Gourmate Code", message: "Found \(code)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = mates.filter({ (mate) -> Bool in
            let tmp: String = mate.name
            return tmp.hasPrefix(searchText)
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.allMatesTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == allMatesTable {
            if(searchActive) {
                return filtered.count
            }
            return mates.count;
        } else {
            return selected.count;
        }
    }
    
    // Action for selecting row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Selecting on Mates table will move mate to selected group table
        print(selected)
        if tableView == allMatesTable {
            let user = self.searchActive ? filtered[indexPath.row] : mates[indexPath.row]
            self.addMate(mate: user)
            self.allMatesTable.deselectRow(at: indexPath, animated: true)
            // Selecting on Selected group table will move mate back
        } else {
            let user = selected[indexPath.row]
            if let index = selected.firstIndex(of: user) {
                let refreshAlert = UIAlertController(title: "Remove Mate", message: "Are you sure you want to remove this mate from your group?", preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    if user.email == curUserEmail{
                        let selfAlert = UIAlertController(title: "Uh Oh!", message: "You can't remove yourself from the Group!", preferredStyle: UIAlertController.Style.alert)
                        selfAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(selfAlert, animated: true, completion: nil)
                    } else {
                        self.selected.remove(at: index)
                        self.selectedMatesTable.reloadData()
                    }
                }))
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Handle Cancel Logic here")
                }))
                
                present(refreshAlert, animated: true, completion: nil)
            }
        }
        self.selectedMatesTable.reloadData()
    }
    
    
    func addMate(mate:MateObject){
        if !selected.contains(mate) {
            self.selected.append(mate)
            self.selectedMatesTable.reloadData()
        } else {
            let refreshAlert = UIAlertController(title: "Already Contains", message: "Your group already contains \(mate.name)", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    // Send selected users to other screens
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "makeGroupIdentifier", let nextVC = segue.destination as?
            SuggestionsViewController {
            nextVC.selectedUsers = self.selected
        }
        if segue.identifier == "groupAnalysisSegue", let nextVC = segue.destination as?
            GroupAnalysisViewController {
            nextVC.selectedUsers = self.selected
        }
    }
    
    // Data in the row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mateCell", for: indexPath) as! MateCell
        let source = tableView == allMatesTable ? self.searchActive ? self.filtered : self.mates : selected;
        let mate = source == selected ? source[indexPath.row] : source[indexPath.row]
        cell.mateName.text = mate.name
        let imageURL = URL(string: mate.image)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: imageURL!)
            DispatchQueue.main.async {
                cell.mateImage.image = UIImage(data: data!)
            }
        }
        return cell
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
