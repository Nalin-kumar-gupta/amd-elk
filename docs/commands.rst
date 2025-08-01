Useful Commands for Development
===============================

---

Flutter Commands
-----------------

1. **flutter run**
   Runs your Flutter app on the connected device or emulator.
   Use ``-d device_id`` to specify a device if multiple are connected.

2. **flutter pub get**
   Fetches all the dependencies listed in your ``pubspec.yaml``.

3. **flutter pub add <package_name>**
   Adds a package to your ``pubspec.yaml`` and fetches it.
   Example: ``flutter pub add http`` (to add the HTTP package).

4. **flutter clean**
   Deletes the ``build`` folder and clears the cached data to fix build-related issues.

5. **flutter doctor**
   Diagnoses issues in your Flutter setup, such as missing dependencies or version mismatches.

6. **flutter build apk**
   Builds a release APK for Android.

7. **flutter build ios**
   Builds the app for iOS. Requires Xcode.

8. **flutter upgrade**
   Updates Flutter SDK and all dependencies to the latest versions.

9. **flutter analyze**
   Analyzes your code for potential errors or warnings.

10. **flutter format .**
    Formats all Dart files in the current directory for consistency.

---

Gradle Commands (**cd ./android**)
---------------

1. **./gradlew clean**
   Cleans the build directory. Useful for resolving Gradle build cache issues.

2. **./gradlew build**
   Builds the project using Gradle.

3. **./gradlew assembleDebug**
   Builds a debug APK for Android.

4. **./gradlew assembleRelease**
   Builds a release APK for Android.

5. **./gradlew dependencies**
   Lists all dependencies and their versions for your project.

---

Elasticsearch Commands
----------------------

1. **Delete an Elasticsearch Database**
   ::

       curl -X DELETE "http://<ES_HOST>:9200/<INDEX_NAME>"

   Example:
   ::

       curl -X DELETE "http://144.126.254.135:9200/my-index"

2. **Get One Log from Elasticsearch**
   ::

       curl -X GET "http://<ES_HOST>:9200/<INDEX_NAME>/_search?size=1"

   Example:
   ::

       curl -X GET "http://144.126.254.135:9200/winlogbeat-*/_search?size=1"

3. **Query Logs with a Match Query**
   ::

       curl -X GET "http://<ES_HOST>:9200/<INDEX_NAME>/_search" -H 'Content-Type: application/json' -d '{
         "query": {
           "match": {
             "field_name": "value"
           }
         }
       }'

   Example:
   ::

       curl -X GET "http://144.126.254.135:9200/winlogbeat-*/_search" -H 'Content-Type: application/json' -d '{
         "query": {
           "match": {
             "log.level": "error"
           }
         }
       }'

4. **View Cluster Health**
   ::

       curl -X GET "http://<ES_HOST>:9200/_cluster/health?pretty"

5. **Create an Index**
   ::

       curl -X PUT "http://<ES_HOST>:9200/<INDEX_NAME>" -H 'Content-Type: application/json' -d '{
         "settings": {
           "number_of_shards": 1,
           "number_of_replicas": 1
         }
       }'

6. **Insert a Document**
   ::

       curl -X POST "http://<ES_HOST>:9200/<INDEX_NAME>/_doc" -H 'Content-Type: application/json' -d '{
         "field1": "value1",
         "field2": "value2"
       }'

7. **Bulk Insert Documents**
   Use the ``_bulk`` API for high-efficiency data insertion.

---

General Development Commands
----------------------------

1. **List Processes Running on Ports**
   ::

       lsof -i :<PORT_NUMBER>

   Example:
   ::

       lsof -i :9200

2. **Kill a Process by Port**
   ::

       kill -9 $(lsof -t -i:<PORT_NUMBER>)

3. **View Logs in Real-Time**
   ::

       tail -f /path/to/logfile.log

4. **Search Logs for a Specific Term**
   ::

       grep "term" /path/to/logfile.log

5. **Check Disk Usage**
   ::

       df -h

6. **Check Memory Usage**
   ::

       free -h

7. **Monitor System Performance**
   ::

       top

8. **Start a Simple HTTP Server**
   ::

       python3 -m http.server <PORT>

   Example:
   ::

       python3 -m http.server 8000

9. **Download a File Using wget**
   ::

       wget <URL>

10. **View Open Network Connections**
    ::

        netstat -an

---

Let me know if you need additional commands or modifications!