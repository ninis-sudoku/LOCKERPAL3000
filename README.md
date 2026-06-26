# 🔐 LOCKERPAL3000

## Overview

**LOCKERPAL3000** is an IoT-based Smart Locker developed as a college capstone project by a team of four students between **June 2025 and April 2026(2 Semesters)**.

The project was created to explore the fundamentals of **Internet of Things (IoT), embedded systems, and software development** while addressing the limitations of traditional lock-and-key storage systems.

> **Note:** This project is an academic prototype built under limited time, funding, hardware resources, and with the help of AI. The primary goal was learning and experimentation rather than developing a production-ready system. Some features may require further refinement before real-world deployment.

---

## Features

* 🔑 Dual authentication using **RFID cards** and a **mobile application**
* 📱 Remote locker unlocking via mobile phone
* 📡 Proximity detection that reminds users if the locker is left unlocked
* 🚨 Forced-open detection with buzzer alerts
* 📊 Locker activity logging and basic analytics
* ☁️ IoT integration for real-time monitoring

---

## Team

| Role                      | Member       |
| ------------------------- | ------------ |
| Project Leader            | *[Redacted]* |
| Main Hardware Engineer    | *[Redacted]* |
| Main Programmer           | *[Redacted]* |
| Main Designer & Presenter | *[Redacted]* |

> These titles indicate the primary person responsible for each area. Every team member contributed collaboratively throughout the project.

---

## Project Documentation

The complete project report is **confidential** and cannot be published.

The project's development documentation is not included in this repository, as it contains internal materials that are not intended for public distribution.

This README provides an overview of the project's objectives, implementation scope, and technical design.

---

# Project Objectives

### Objective 1

Identify the limitations of traditional lock-and-key systems—particularly security weaknesses, lack of monitoring, and absence of real-time notifications—in order to develop a more effective smart locker solution.

### Objective 2

Design and develop an IoT-based Smart Locker that integrates a dual authentication system using RFID and a mobile application to improve security, accessibility, and user convenience.

### Objective 3

Test and validate the proposed system to ensure reliable authentication, real-time data synchronization, and responsive system performance.

---

# Project Scope

## Implementation

### RFID Authentication

* RFID reader for user authentication
* Authorized RFID tags are registered in the database
* Access is granted only to verified users

### Mobile Application & IoT Integration

* Wireless communication between the locker and mobile application
* Remote unlocking
* Locker status monitoring
* User management through secure communication

### Embedded System

* ESP32-based microcontroller
* Controls authentication, communication, and electronic solenoid lock
* Provides real-time processing and automatic locking

---

## System Capabilities

* Dual authentication (RFID + mobile application)
* Real-time locker status monitoring
* Remote locking and unlocking
* Access log recording
* Authorized user management

---

# Project Limitations

### Network Dependency

Remote access relies on a stable wireless connection. Poor connectivity may affect system responsiveness.

### Prototype Scale

The project was evaluated using a small-scale prototype due to time and budget constraints. Performance under large-scale deployment has not been tested.

### Hardware Constraints

The prototype uses entry-level IoT hardware (ESP32 + CP2102). While suitable for educational purposes, these components may not provide the reliability or durability required for industrial applications.

---

# Hardware

## Core Components

- 2 × NodeMCU ESP32 (CP2102 USB)
- RC522 RFID Module
- PS-3150 Magnetic Reed Switch
- INA219 Current Sensor
- Active Piezo Buzzer (5 V DC)
- 5V 3A AC-to-DC Power Adapter

## Electronic Components

- IRLZ44N N-Channel MOSFET
- 1N4007 Rectifier Diode
- 100 Ω Resistor
- 100 kΩ Resistor
- 1000 µF 25 V Electrolytic Capacitors

## Wiring & Prototyping

- Full-size Breadboards
- Dupont Jumper Wires
- Stranded Hook-up Wire
- 2-Pin JST Connector
- Heat-Shrink Tubing
- USB to Micro-USB Cable

---

# Software & Technologies

- Flutter SDK
- Android Studio
- Visual Studio Code (VS Code)
- Firebase

---

# UI Design
[LOCKERPAL300_UI_DESIGN.pdf](https://github.com/user-attachments/files/29386738/LOCKERPAL300_UI_DESIGN.pdf)

---

# Circuit Diagram

<img width="940" height="1060" alt="Circuit Diagram" src="https://github.com/user-attachments/assets/320c075b-42a0-4ec7-9267-a70b8fd03862" />

---

# Physical Prototype

[PHYSICAL_LOCKERPAL3000.pdf](https://github.com/user-attachments/files/29387152/PHYSICAL_LOCKERPAL3000.pdf)

---
# Analytics
<img width="719" height="446" alt="image" src="https://github.com/user-attachments/assets/d44e4bdf-5240-4897-b8a5-e3b374e5b01f" />

# Future Improvements

* Improve authentication security (e.g., encryption and token-based authentication)
* Support multiple lockers within a single management system
* Enhance the mobile application's user interface and user experience
* Implement battery backup for power outages
* Expand analytics and reporting features
* Upgrade to industrial-grade hardware for improved reliability

---
## Acknowledgements

This project made use of AI-assisted tools during development, primarily for brainstorming, debugging, code explanations, documentation refinement, and general learning. All implementation decisions, integration, testing, and final deliverables were reviewed and completed by the project team.

AI tools used:
- ChatGPT
- Copilot
- Perplexity
- Research Rabbit

---
# Educational Purpose

This repository is intended to showcase our learning journey in embedded systems, IoT, and software engineering. While the project demonstrates a functional proof of concept, it is not intended for commercial or production use without further development.
