#Performing an installation
Rapid Install offers two options for a new installation: a standard installation, which involves creating a new system using system-specific configuration parameters, and an Express installation, where Rapid Install supplies default values for many parameters, requiring only a few to be supplied by the user carrying out the install.

This chapter covers the following topics:

* [Standard Installation](#)
* [Express Installation](#)
* [What To Do Next](#)

##Standard Installation
This section describes the setup steps for a standard installation, where the user supplies various system-specific parameters. An Express installation is described in [Setting Up an Express Installation](#).

**Important**: Before you perform the steps described in this section, you must have created a stage area using the buildStage script, as described in the Set up the Stage Area section of Chapter 1.

Follow the instructions in the section [Before You Begin](#) in [Getting Started](#). Then complete the following tasks, which are grouped into logical sections.

**Important**: You do not carry out the installation steps on every node that will be part of your Oracle E-Business Suite system. You carry them out on the database node and primary Applications node, apply the latest release update packs, then use standard cloning commands to scale up to the required number of Applications nodes. The applicable cloning procedures are also mentioned in the relevant sections of this book.

###Describe System Configuration
1. **Start the Rapid Install wizard**

    Start the wizard from the command line by entering rapidwiz at the prompt. The Welcome screen lists the database and the technology stack components that are installed with Oracle E-Business Suite.

    This screen lists the components that are included in, or supported by, this release of Oracle E-Business Suite. You can expand the component lists, using the scroll bar to bring all the components into view.

    A new installation includes a fresh Oracle 11g Release 2 (11gR2) database. In an upgrade, Rapid Install can optionally create an Oracle 11gR2 database Oracle Home without a database. You can use this Oracle Home to upgrade or migrate your existing database to Oracle 11gR2. Alternatively, you can choose to use a suitable existing Oracle Home.

    **Note**: See Oracle E-Business Suite Upgrade Guide: Release 12.0 and 12.1 to Release 12.2.0.
    
    **Welcome Screen**
    
    ![Rig49_Welcome.gif](../../../public/imgs/Rig49_Welcome.gif)
    
    This screen is for information only. No decisions need to be made. When you have reviewed the information, click Next to continue.

2. **Select a wizard operation**

    Use the Select Wizard Operation screen to indicate the action you want Rapid Install to perform. You begin both new installations and upgrades from this screen. Based on the action you choose, the Rapid Install wizard continues with the appropriate screen flow.

    **Select Wizard Operation - Install Oracle E-Business Suite Release 12.2.0**
    
    ![ig_ch2_choosewizardop.gif](../../../public/imgs/ig_ch2_choosewizardop.gif)
    
    The available actions are as follows:
    * Install Oracle E-Business Suite Release 12.2.0

        This action sets up a new, fully configured system, with either a fresh database or a Vision Demo database. The configuration is derived from the system-specific configuration parameters you will enter in the Rapid Install wizard and save in the Oracle E-Business Suite database (conf_&lt;SID&gt;.txt file initially, until the database has been created).
        .
    * Express Configuration

        This install option sets up a fully configured, single-user system with either a fresh database or Vision Demo database. You supply a few basic parameters, such as database type and name, top-level install directory, and choice of port pools. The remaining directories and mount points are supplied by Rapid Install using default values.

        **Note**: The steps in [Setting Up an Express Installation](#) in this chapter describe this option.
        .
    * Upgrade to Oracle E-Business Suite Release 12.2.0

        Choose this option to indicate that you are upgrading your E-Business Suite products to the current version of Oracle E-Business Suite. The wizard screen flow presents two paths: one that lays down the file system and installs the new technology stack, and one that configures servers and starts services.

        **Note**: See [Performing an Upgrade](#) to learn how Rapid Install works during a system upgrade.

    Using the following steps, you will set up a new installation. Choose Install Oracle E-Business Suite Release 12.2.0 and then click Next to continue.

3. **Supply email details for security updates**
    