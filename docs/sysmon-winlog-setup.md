# **Windows Log Capturing with Sysmon, Winlogbeat, and ELK (on Docker)**

---

## **File Structure to Follow**
- **Windows** (Sysmon and Winlogbeat):
  ```
  C:\
   ├── Program Files\
   │    └── Winlogbeat\
   └── sysmon.xml
  ```

---

## **Step 1: Install and Configure Sysmon on Windows**

Sysmon helps track system activities, including process creations and network connections.

1. **Download Sysmon**:
   - Go to [Microsoft Sysinternals](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) and download the latest Sysmon ZIP file.

2. **Extract Sysmon**:
   - Extract the contents (e.g., `sysmon64.exe` and `Eula.txt`) to:
     ```plaintext
     C:\Sysmon\
     ```

3. **Download a Configuration File**:
   - Use the [SwiftOnSecurity Sysmon config](https://github.com/SwiftOnSecurity/sysmon-config):
     1. Download **sysmonconfig-export.xml**.
     2. Save it to:
        ```plaintext
        C:\sysmon.xml
        ```

4. **Install Sysmon**:
   - Open **Command Prompt** as **Administrator** and run:
     ```bash
     sysmon64.exe -accepteula -i C:\sysmon.xml
     ```

5. **Verify Sysmon Installation**:
   ```bash
   sc query sysmon
   ```
   - You should see that Sysmon is **Running**.

---

## **Step 2: Install and Configure Winlogbeat on Windows**

### 2.1 Download and Install Winlogbeat
1. **Download Winlogbeat**:
   - Go to [Elastic’s website](https://www.elastic.co/downloads/beats/winlogbeat) and download the latest Winlogbeat ZIP file.

2. **Extract the ZIP file** to:
   ```plaintext
   C:\Program Files\Winlogbeat\
   ```

3. **Set Execution Policy for PowerShell**:
   - Open **PowerShell** as Administrator and run:
     ```bash
     Set-ExecutionPolicy Unrestricted -Scope Process
     ```

4. **Modify Winlogbeat Configuration File**:
   - Open:
     ```plaintext
     C:\Program Files\Winlogbeat\winlogbeat.yml
     ```

   - Modify the `winlogbeat.yml` as follows:

     ```yaml
     winlogbeat.event_logs:
       - name: Microsoft-Windows-Sysmon/Operational
       - name: Security
         event_id: 4624, 4625, 4672  # Include desired event IDs

     output.logstash:
       hosts: ["<your_digital_ocean_server_ip>:5044"]
     ```

5. **Install the Winlogbeat Service**:
   - In **PowerShell**, run:
     ```bash
     cd "C:\Program Files\Winlogbeat"
     .\install-service-winlogbeat.ps1
     ```

6. **Start Winlogbeat**:
   ```bash
   Start-Service winlogbeat
   ```

7. **Verify the Service**:
   ```bash
   Get-Service winlogbeat
   ```

---

## **Step 3: Create an Index Pattern in Kibana**

1. **Access Kibana**:
   - Open your browser and go to:
     ```
     http://<your_digital_ocean_server_ip>:5601
     ```

2. **Log In**:
   - **Username:** `elastic`
   - **Password:** `password`

3. **Create an Index Pattern**:
   1. Go to **Stack Management > Index Patterns**.
   2. Click **Create Index Pattern**.
   3. Enter:
      ```
      winlogbeat-*
      ```
   4. Select **@timestamp** as the time field.
   5. Click **Create Index Pattern**.

---

## **Step 4: View Logs in Kibana**

1. **Go to Discover**:
   - In Kibana, click **Discover** from the sidebar.

2. **Select the Index Pattern**:
   - Choose **winlogbeat-*** from the dropdown.

3. **Adjust Time Range**:
   - In the top-right corner, click the **Time Filter** and expand the range (e.g., **Last 24 hours** or **This Week**).

---


---

## **Step 5: Generate Test Events**

1. **Trigger a Login Event**:
   - Lock and unlock your Windows machine.

2. **Trigger a Sysmon Event**:
   ```bash
   ping 127.0.0.1
   ```

---

