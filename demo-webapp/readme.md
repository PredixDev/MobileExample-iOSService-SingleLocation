1. Ensure you are in the demo-webapp folder

  ```
  cd <repo>/demo-webapp
  ```

2. Ensure you are authorized using the Predix Mobile CLI

  ```
  pm auth <username>
  ```

3. Install the webapp's dependences

  ```
  npm install
  ```
  
3. Build and publish the webapp

  ```
  npm run publish
  ```

4. Define your app (this uses the included app.json)

  ```
  pm define
  ```

5. Update the `info.plist` for the Predix Mobile Container app in Xcode to match the app name and version in the app.json.

6. Run the app in Xcode.