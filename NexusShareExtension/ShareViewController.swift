//
//  ShareViewController.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    var sharedURLs: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let supportedUTIs = [
            UTType.pdf.identifier,
            UTType.spreadsheet.identifier,
            UTType.data.identifier
        ]

        let group = DispatchGroup()
        if let items = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in items {
                if let providers = item.attachments {
                    for provider in providers {
                        group.enter()
                        let typeIdentifier = provider.registeredTypeIdentifiers
                            .first { supportedUTIs.contains($0) } ?? UTType.data.identifier
                        provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, _ in
                            if let url = url {
                                let tmpURL = FileManager.default.temporaryDirectory
                                    .appendingPathComponent(url.lastPathComponent)
                                try? FileManager.default.removeItem(at: tmpURL)
                                try? FileManager.default.copyItem(at: url, to: tmpURL)
                                self.sharedURLs.append(tmpURL)
                            }
                            group.leave()
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            if !self.sharedURLs.isEmpty {
                self.presentShareUI()
            } else {
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
        }
    }

    private func presentShareUI() {
        guard !sharedURLs.isEmpty else { return }
        // Wrap your SwiftUI ShareContentView
        let content = ShareContentView(
            sharedURLs: sharedURLs,
            onSave: { fileURL, folder, name in
                try? SharedFileManager.save(file: fileURL, to: folder, named: name)
                return SharedFileManager.documentsURL
                    .appendingPathComponent(folder, isDirectory: true)
                    .appendingPathComponent(name)
            },
            onOpen: { saved in
                let base = SharedFileManager.documentsURL.path + "/"
                let relative = saved.path.replacingOccurrences(of: base, with: "")
                if let url = URL(string: "nexusfileapp://\(relative)") {
                    self.extensionContext?.open(url, completionHandler: nil)
                }
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
        )
        let host = UIHostingController(rootView: content)
        addChild(host)
        host.view.frame = view.bounds
        view.addSubview(host.view)
        host.didMove(toParent: self)
    }
}
