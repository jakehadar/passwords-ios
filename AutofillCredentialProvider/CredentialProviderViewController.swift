//
//  CredentialProviderViewController.swift
//  AutofillCredentialProvider
//
//  Created by James Hadar on 10/21/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import AuthenticationServices

public let kAppGroup = "group.ar.had.Passwords"

class CredentialProviderViewController: ASCredentialProviderViewController {
    var passwordService: AnyObject? = nil
    var keychain = KeychainWrapper(serviceName: "ar.had.Passwords", accessGroup: kAppGroup)
    var identifiers = [ASCredentialServiceIdentifier]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    
    // MARK: - Autofill UI
    
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
    */
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        doneButton.isEnabled = false
        collectionView.register(CredentialProviderCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        identifiers = serviceIdentifiers
    }

    /*
     Implement this method if your extension supports showing credentials in the QuickType bar.
     When the user selects a credential from your app, this method will be called with the
     ASPasswordCredentialIdentity your app has previously saved to the ASCredentialIdentityStore.
     Provide the password by completing the extension request with the associated ASPasswordCredential.
     If using the credential would require showing custom UI for authenticating the user, cancel
     the request with error code ASExtensionError.userInteractionRequired.
     */
    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        let databaseIsUnlocked = true
        if (databaseIsUnlocked) {
            let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        } else {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
        }
    }
    

    /*
     Implement this method if provideCredentialWithoutUserInteraction(for:) can fail with
     ASExtensionError.userInteractionRequired. In this case, the system may present your extension's
     UI and call this method. Show appropriate UI for authenticating the user then provide the password
     by completing the extension request with the associated ASPasswordCredential.
     */
    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }
    
    // MARK: - Settings UI
    
    override func prepareInterfaceForExtensionConfiguration() {
        // Present settings
        doneButton.isEnabled = true
        
        // Call this to dismiss the extension UI when the user is done
        // extensionContext.completeExtensionConfigurationRequest()
    }
    
    // MARK: - Actions

    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        extensionContext.completeExtensionConfigurationRequest()
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }

    @IBAction func passwordSelected(_ sender: AnyObject?) {
        let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }

}

extension CredentialProviderViewController: UICollectionViewDelegate {
    
}

extension CredentialProviderViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return identifiers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CredentialProviderCollectionViewCell
        let identifier = identifiers[indexPath.item]
        cell.textView.text = identifier.identifier
        return cell
    }
    
    
}
