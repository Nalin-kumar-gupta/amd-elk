Here’s the complete guide in Markdown format, with the updates included:

```markdown
# **Windows Log Capturing with Sysmon, Winlogbeat, and ELK (on Docker)**

---

## **File Structure**

To ensure proper organization, follow this directory structure on your Windows machine:

```
C:\
 ├── Program Files\
 │    └── Winlogbeat\
 ├── Tools\
 │    └── Sysmon\
```

---

## **Step 1: Install and Configure Sysmon on Windows**

**Sysmon** is a system monitoring tool that logs system activity, including process creations and network connections. Follow these steps to install and configure it:

1. **Download Sysmon**
   - Navigate to the [Microsoft Sysinternals website](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) and download the latest Sysmon ZIP file.

2. **Extract Sysmon**
   - Extract the contents (e.g., `sysmon64.exe` and `Eula.txt`) to:
     ```
     C:\Tools\Sysmon\
     ```

3. **Download a Configuration File**
   - Acquire the [SwiftOnSecurity Sysmon configuration](https://github.com/SwiftOnSecurity/sysmon-config):
     - Download **sysmonconfig-export.xml**.
     - Save it to:
       ```
       C:\Tools\Sysmon\sysmonconfig-export.xml
       ```

4. **Install Sysmon**
   - Open **Command Prompt** as **Administrator** and execute:
     ```bash
     C:\Tools\Sysmon\sysmon64.exe -accepteula -i C:\Tools\Sysmon\sysmonconfig-export.xml
     ```

5. **Verify Sysmon Installation**
   - Check if Sysmon is running by executing:
     ```bash
     sc query sysmon
     ```
   - Ensure the output indicates that Sysmon is **Running**.

---

## **Step 2: Install and Configure Winlogbeat on Windows**

**Winlogbeat** is a lightweight shipper that forwards and centralizes Windows event logs. Here’s how to set it up:

### 2.1 Download and Install Winlogbeat

1. **Download Winlogbeat**
   - Go to [Elastic’s Winlogbeat download page](https://www.elastic.co/downloads/beats/winlogbeat) and download the latest ZIP file.

2. **Extract the ZIP File**
   - Extract the contents to:
     ```
     C:\Program Files\Winlogbeat\
     ```

3. **Set Execution Policy for PowerShell**
   - Open **PowerShell** as Administrator and run:
     ```bash
     Set-ExecutionPolicy Unrestricted -Scope Process
     ```

4. **Modify Winlogbeat Configuration File**
   - Open the configuration file:
     ```
     C:\Program Files\Winlogbeat\winlogbeat.yml
     ```
   - Update it with the following settings:
     ```yaml
     winlogbeat.event_logs:
       - name: Microsoft-Windows-Sysmon/Operational
       - name: Security
         event_id: 4624, 4625, 4672  # Include desired event IDs

     output.logstash:
       hosts: ["<your_digital_ocean_server_ip>:5044"]
     ```

5. **Install the Winlogbeat Service**
   - In **PowerShell**, run:
     ```bash
     cd "C:\Program Files\Winlogbeat"
     .\install-service-winlogbeat.ps1
     ```

6. **Start Winlogbeat**
   ```bash
   Start-Service winlogbeat
   ```

7. **Verify the Service**
   - Ensure Winlogbeat is running by executing:
     ```bash
     Get-Service winlogbeat
     ```

---

## **Step 3: Create an Index Pattern in Kibana**

To visualize your logs, you need to create an index pattern in Kibana.

1. **Access Kibana**
   - Open your browser and navigate to:
     ```
     http://<your_digital_ocean_server_ip>:5601
     ```

2. **Log In**
   - Enter the following credentials:
     - **Username:** `elastic`
     - **Password:** `password`

3. **Create an Index Pattern**
   - Navigate to **Stack Management > Index Patterns**.
   - Click **Create Index Pattern**.
   - Enter:
     ```
     winlogbeat-*
     ```
   - Select **@timestamp** as the time field.
   - Click **Create Index Pattern**.

---

## **Step 4: View Logs in Kibana**

1. **Go to Discover**
   - Click **Discover** in the sidebar of Kibana.

2. **Select the Index Pattern**
   - From the dropdown, choose **winlogbeat-***.

3. **Adjust Time Range**
   - Click the **Time Filter** in the top-right corner and select your desired time range (e.g., **Last 24 hours** or **This Week**).

---

## **Step 5: Generate Test Events**

To ensure that everything is working correctly, generate some test events.

1. **Trigger a Login Event**
   - Lock and unlock your Windows machine.

2. **Trigger a Sysmon Event**
   - Open **Command Prompt** and execute:
     ```bash
     ping 127.0.0.1
     ```

---

By following these steps, you will successfully set up and monitor logs from Sysmon and Winlogbeat using the ELK stack on Docker.
```

Feel free to make any further adjustments or let me know if you need anything else!
