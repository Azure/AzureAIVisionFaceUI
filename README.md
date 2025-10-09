# Azure AI Vision Face UI SDK for iOS

This repository hosts Azure AI Vision Face UI SDK for iOS platform.

## Prerequisites

1. An Azure Face API resource subscription.
2. A Mac (with iOS development environment, Xcode 13+), an iPhone (iOS 14+).
3. An Apple developer account to install and run development apps on the iPhone.

## Installation

1. **Prepare Xcode environment**: For the best experience, please do not open your application project in Xcode yet before completing the environment setup.

2. **Get PAT access token**: <a id="get-access-token"></a>Fetch the PAT access token required for downloading release artifacts, using the API: [Get Client Assets Access Token](https://learn.microsoft.com/rest/api/face/liveness-session-operations/get-client-assets-access-token?view=rest-face-v1.3-preview)

3. **Install Git LFS**: Prepare Git LFS
   * If you have never installed Git LFS, refer to [Git LFS official site](https://git-lfs.github.com/) for instructions.
   * For example:

      ```sh
      # install with homebrew
      brew install git-lfs
      # verify and initialize
      git lfs --version
      git lfs install
      ```

4. **Configure Git authentication**: The subsequent steps assume your application will reference the SDK through Swift Package Manager (SPM). Configure the authorization of the git repository from which SPM will pull the package:

   4.1. Open your global git config file.

      ```sh
      # path will be shown by the following command, then open it using editor
      git config --global --show-origin --list | head -1
      # alternatively default editor will be used if using the following command
      git config --global --edit
      ```

   4.2. Get the PAT access token from [step 2](#get-access-token) above, then add it to the config:

      ```config
      [credential "https://msface.visualstudio.com"]
              username = pat
              helper =
              helper = "!f() { test \"$1\" = get && echo \"password=INSERT_PAT_HERE\"; }; f"

              # get PAT from Get Client Assets Access Token REST API and paste ^^^^^^^^^^^^^^^ above, replacing "INSERT_PAT_HERE".
              # username does not matter for PAT so long as it is not left blank.
              # the first blank helper line is necessary to override existing helpers and not a typo.
      ```

   * for other methods of dependency such as CocoaPods, or other methods of git authentication, please refer to the [FAQ](#faq) section of this document.

5. **Install Xcode Command Line Tools**: If Xcode Command Line Tools is never installed on your machine, install it first [following instructions from Apple Developer website](https://developer.apple.com/library/archive/technotes/tn2339/_index.html).
## Integrate face liveness detection into your own application

1. Configure your Xcode project
   
   1.1. In **Xcode → Targets → Build Settings → Swift Compiler - Language**, select the **C++ and Objective-C Interoperability** to be **C++ / Objective-C++**
   
   ![C++ / Objective-C++](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/docs/ios/AzureAIVisionFaceUI/1.4.0/img/cplusplus_and_objective_c_interoperability.png)
   
   1.2. In **Xcode → Targets → Info → Custom iOS Target Properties**, add **[Privacy - Camera Usage Description](https://developer.apple.com/documentation/bundleresources/information-property-list/nscamerausagedescription)**.
   
   ![Privacy - Camera Usage Description](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/docs/ios/AzureAIVisionFaceUI/1.4.0/img/privacy_camera_usage_description.png)

2. Add package dependency by adding AzureAIVisionFaceUI in **Xcode → Files → Add Package Dependencies** for Swift Package Manager. See [FAQ](#faq) for other dependency management tools.
   
   ![Xcode → Files → Add Package Dependencies](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/docs/ios/AzureAIVisionFaceUI/1.4.0/img/xcode_files_add_package_dependencies.png)
   
   2.1. In **Search or Enter Package URL** text box, enter `https://github.com/Azure/AzureAIVisionFaceUI`.
   
   ![https://github.com/Azure/AzureAIVisionFaceUI](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/docs/ios/AzureAIVisionFaceUI/1.4.0/img/add_package_azureaivisionfaceui.png)
   
   2.2. Add the package
   
   ![Add Package](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/docs/ios/AzureAIVisionFaceUI/1.4.0/img/add_package_azureaivisionfaceui_add.png)
   
   2.3. Package resolution will fail. Select **Add Anyway**.
   
   ![Add Anyway](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/docs/ios/AzureAIVisionFaceUI/1.4.0/img/add_package_azureaivisionfaceui_add_anyway.png)
   
   2.4. AzureAIVisionFaceUI will show up under **Package Dependencies** with red crossed icon.
   
   ![Package not resolved](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/docs/ios/AzureAIVisionFaceUI/1.4.0/img/package_not_resolved.png)
   
   2.5. Close Xcode window of your project.
   
   2.6. Run the following command from Terminal, from the directory where your .xcodeproj is located, as appropriate for your project. It will resolve the package through your system Git. Your system Git should already have Git LFS configured, as mentioned in Prerequisites section.

      ```sh
      xcodebuild -scmProvider system -resolvePackageDependencies
      ```

   2.7. After the command succeeds, open the project again in Xcode. The package should be resolved properly.
   
   ![Package resolved](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/docs/ios/AzureAIVisionFaceUI/1.4.0/img/package_resolved.png)

3. Insert `FaceLivenessDetectorView`. Respond to the update of the passed binding in your `View`.

   ```swift
   struct HostView: View {
       @State var livenessDetectionResult: LivenessDetectionResult? = nil
       var token: String
       var body: some View {
           if livenessDetectionResult == nil {
               FaceLivenessDetectorView(result: $livenessDetectionResult,
                                        sessionAuthorizationToken: token)
           } else if let result = livenessDetectionResult {
               VStack {
                   switch result { 
                       case .success(let success):
                       /// <#show success#>
                       case .failure(let error):
                       /// <#show failure#>
                   }
               }
           }
       }
   }
   ```

4. Obtain the session authorization token from your service and update the view accordingly. For more information on how to orchestrate the liveness flow by utilizing the Azure AI Vision Face service, visit: https://aka.ms/azure-ai-vision-face-liveness-tutorial.


5. Compare `digest` from both the client's `LivenessDetectionSuccess` instance and service response to ensure integrity. For more details, see [DeviceCheck | Apple Developer Documentation](https://developer.apple.com/documentation/devicecheck)

## FAQ

### Q: How do we use CocoaPods or other package managers?

Add the following lines to your project's Podfile. `'YourBuildTargetNameHere'` is an example target, and you should use your actual target project instead. You can also [specify your version requirement](https://guides.cocoapods.org/using/the-podfile.html#specifying-pod-versions) as needed.

```ruby
# add repo as source
source 'https://msface.visualstudio.com/SDK/_git/AzureAIVisionFaceUI.podspec'
target 'YourBuildTargetNameHere' do
   # add the pod here, optionally with version specification as needed
   pod 'AzureAIVisionFaceUI'
end
```

Also read: CocoaPods ([CocoaPods Guides - Getting Started](https://guides.cocoapods.org/using/getting-started.html))

For other package managers, please consult their documentation and clone the framework repo manually.

### Q: Are there alternatives for access authorization?

There are some situations where the example plaintext token inside global `git-config` may not be suitable for your needs, such as automated build machines.

If you are using `git-credential-manager`, `credential.azreposCredentialType` needs to be set to `pat`.

The example above uses `credential.helper` approach of `git-config`. Aside from storing it directly inside the config file, there are alternate ways to provide the token to `credential.helper`. Read [custom helpers section of the `gitcredentials` documentation](https://git-scm.com/docs/gitcredentials#_custom_helpers) for more information.

To use [`http.extraHeader` approach of `git-config`](https://git-scm.com/docs/git-config/2.22.0#Documentation/git-config.txt-httpextraHeader), you need to convert the token to base64 format. Refer to [the **Use a PAT** section of this Azure DevOps documentation article](https://learn.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Linux#use-a-pat). Note that instead of using the git clone invocation as shown in the example, you should call:

```sh
MY_PAT=accessToken
HEADER_VALUE=$(printf "%s" "$MY_PAT" | base64)
git config --global http.https://msface.visualstudio.com/SDK.extraHeader "Authorization: Basic ${HEADER_VALUE}"
```

For other types of Git installation, refer to [the **Credentials** section of Git FAQ](https://git-scm.com/docs/gitfaq#_credentials).

### Q: How can I get the results of the liveness session?

Once the session is completed, for security reasons the client does not receive the outcome whether face is live or spoof.

You can query the result from your backend service by calling the sessions results API to get the outcome [[API Reference](https://aka.ms/face/liveness-session/get-liveness-session-result)].

### Q: How do I provide localization?

The SDK provides default localization for 75 locales. The strings can be customized for each localization by following this guide by Apple: [Localizing and varying text with a string catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog). Please refer to [this document](https://aka.ms/face/liveness/sdk/docs/localization) for the keys of the strings.

### Q: How do I customize the displayed strings?

Please refer to the localization FAQ answer above.

<!-- markdownlint-configure-file
{
  "no-inline-html": {
    "allowed_elements": [
      'br'
    ]
  }
}
-->


