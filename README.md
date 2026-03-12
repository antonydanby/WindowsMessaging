# Windows Messaging for Delphi
A lightweight, component-based wrapper for inter-process communication (IPC) in Delphi using the WM_COPYDATA protocol. This package allows you to send and receive strings or data structures between separate Windows applications with minimal configuration.

## 📁 Project Structure
/: Contains the l53n component package and group

Source/: Contains the classes and the common unit

Demo/: A VCL application demonstrating how to send messages.

Demo/: A VCL application demonstrating how to catch and process messages.

WindowsMessagingGroup.groupproj: The master project group to open everything at once.

## 🚀 Features
TWMsgSender: A non-visual component to dispatch data to specific windows.

TWMsgReceiver: A component that registers a unique window name and triggers an event when data arrives.

Zero-Config IPC: No named pipes or sockets required; uses the native Windows message queue.

High-DPI Ready: Includes custom icons for the Delphi 13 Tool Palette.

## 🛠 Installation
1. Install the Package
Open WindowsMessagingGroup.groupproj 
This was developed in Rad Studio 13, but it should run in any modern version of Delphi or Rad Studio, including the community edition. If this is not the case please contact me on the contact details below

Right-click on WindowsMessaging.bpl in the Project Manager.

Select Build, then Install.

You will now find the components in the Tool Palette under the l53n category.

2. Library Path
Ensure the folder containing your .dcp and .dcu files is added to your Delphi Library Path (Tools > Options > IDE > Environment Variables).

## 📖 Usage Example
Although you can drop the component onto a form or a DataModule in the VCL you can in fact use it anywhere by simply creating it on the fly. 

There are many scenarios I can think of where this component would be useful. Such as:

1. Communicating with a Service to get status and other information back
2. Communications between DLL and DLL or EXE and DLL as usually this kind of communication can be quite difficult
3. To serve as a Watchdog for another application

There is a demo for both the Sender and the Receiver showing how to use them both, just remember to click Start on the Receiver first.

## ⚠️ Important Notes
Window Names: WM_COPYDATA relies on finding the target window handle by name. Ensure your WindowName is unique to avoid collisions with other apps.

Data Limits: While WM_COPYDATA is efficient, it is intended for small-to-medium data packets. For multi-gigabyte transfers, consider memory-mapped files.

# 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

---

## 📩 Contact & Support

If you have questions, find a bug, or want to suggest a feature for the **Windows Messaging Group**, feel free to reach out:

* **Maintainer:** Antony Danby
* **GitHub:** [@AntonyDanby](https://github.com/antonydanby)  
* **Email:** [info@latitude53north.co.uk](mailto:info@latitude53north.co.uk)  
* **Website:** [latitude53north.co.uk](https://latitude53north.co.uk)

> [!TIP]
> If you encounter an issue with window handle detection, please include your Windows version and Delphi edition in the [Issue Tracker](https://github.com/antonydanby/WindowsMessaging/issues).
>
> 