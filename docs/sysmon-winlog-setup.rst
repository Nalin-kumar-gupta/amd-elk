============================
Windows Log Capturing with Sysmon, Winlogbeat, and ELK (on Docker)
============================

This guide will walk you through setting up Sysmon and Winlogbeat to capture Windows logs and visualize them using the ELK stack on Docker.

-----------------------------------
File Structure
-----------------------------------

Ensure the following directory structure on your Windows machine:

.. code-block:: text

    C:\
     ├── Program Files\
     │    └── Winlogbeat\
     ├── Tools\
     │    └── Sysmon\

-----------------------------------
Step 1: Install and Configure Sysmon
-----------------------------------

**Sysmon** logs system activities like process creations and network connections. Follow these steps to install and configure it:

1. **Download Sysmon**
   - Go to the `Microsoft Sysinternals website <https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon>`_ and download the latest Sysmon ZIP file.

2. **Extract Sysmon**
   - Extract the contents (e.g., `sysmon64.exe` and `Eula.txt`) to the following directory:

   .. code-block:: bash

     C:\Tools\Sysmon\

3. **Download a Configuration File**
   - Get the `SwiftOnSecurity Sysmon configuration <https://github.com/SwiftOnSecurity/sysmon-config>`_.
   - Download the **sysmonconfig-export.xml** file and save it to:

   .. code-block:: bash

     C:\Tools\Sysmon\sysmonconfig-export.xml

4. **Install Sysmon**
   - Open **Command Prompt** as **Administrator** and run the following command to install Sysmon with the configuration file:

   .. code-block:: bash

     C:\Tools\Sysmon\sysmon64.exe -accepteula -i C:\Tools\Sysmon\sysmonconfig-export.xml

5. **Verify Sysmon Installation**
   - Ensure Sysmon is running by executing this command:

   .. code-block:: bash

     sc query sysmon

   - The output should indicate that Sysmon is **Running**.

-----------------------------------
Step 2: Install and Configure Winlogbeat
-----------------------------------

**Winlogbeat** forwards Windows event logs to a central location. Follow these steps to set it up:

### 2.1 Download and Install Winlogbeat

1. **Download Winlogbeat**
   - Go to `Elastic’s Winlogbeat download page <https://www.elastic.co/downloads/beats/winlogbeat>`_ and download the latest ZIP file.

2. **Extract the ZIP File**
   - Extract the contents to the following directory:

   .. code-block:: bash

     C:\Program Files\Winlogbeat\

3. **Set Execution Policy for PowerShell**
   - Open **PowerShell** as Administrator and execute this command to allow scripts to run:

   .. code-block:: bash

     Set-ExecutionPolicy Unrestricted -Scope Process

4. **Modify Winlogbeat Configuration**
   - Open the Winlogbeat configuration file located at:

   .. code-block:: bash

     C:\Program Files\Winlogbeat\winlogbeat.yml

   - Update the configuration with the following content:

   .. code-block:: yaml

     winlogbeat.event_logs:
       - name: Microsoft-Windows-Sysmon/Operational
       - name: Security
         event_id: 4624, 4625, 4672  # Include desired event IDs

     output.logstash:
       hosts: ["<your_digital_ocean_server_ip>:5044"]

5. **Install Winlogbeat as a Service**
   - In **PowerShell**, navigate to the Winlogbeat directory and run the installation script:

   .. code-block:: bash

     cd "C:\Program Files\Winlogbeat"
     .\install-service-winlogbeat.ps1

6. **Start Winlogbeat**
   - Start the Winlogbeat service by executing this command:

   .. code-block:: bash

     Start-Service winlogbeat

7. **Verify the Winlogbeat Service**
   - Ensure Winlogbeat is running by executing:

   .. code-block:: bash

     Get-Service winlogbeat

-----------------------------------
Step 3: Create an Index Pattern in Kibana
-----------------------------------

To visualize your logs in Kibana, follow these steps to create an index pattern.

1. **Access Kibana**
   - Open your browser and navigate to:

   .. code-block:: bash

     http://<your_digital_ocean_server_ip>:5601

2. **Log In**
   - Use the following credentials:
     - **Username:** `elastic`
     - **Password:** `password`

3. **Create an Index Pattern**
   - Go to **Stack Management > Index Patterns**.
   - Click **Create Index Pattern** and enter:

   .. code-block:: bash

     winlogbeat-*

   - Select **@timestamp** as the time field.
   - Click **Create Index Pattern**.

-----------------------------------
Step 4: View Logs in Kibana
-----------------------------------

1. **Go to Discover**
   - Click **Discover** in the Kibana sidebar.

2. **Select the Index Pattern**
   - From the dropdown, choose **winlogbeat-***.

3. **Adjust Time Range**
   - Click the **Time Filter** in the top-right corner and choose your desired time range (e.g., **Last 24 hours** or **This Week**).

-----------------------------------
Step 5: Generate Test Events
-----------------------------------

To ensure everything is working correctly, generate test events.

1. **Trigger a Login Event**
   - Lock and unlock your Windows machine.

2. **Trigger a Sysmon Event**
   - Open **Command Prompt** and run this command to generate a network-related event:

   .. code-block:: bash

     ping 127.0.0.1

-----------------------------------
