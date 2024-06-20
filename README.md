EarthquakeMonitor

EarthquakeMonitor is an iOS application that provides real-time information on recent earthquakes using data from the USGS Earthquake API. The application follows the MVVM architecture and leverages Combine for reactive programming. Users can view earthquake details in a list and visualize them on a map.

Table of Contents

Features
Architecture
Setup
Usage
Screenshots
Project Structure
Dependencies
Security
Testing
Contributing
License
Features

Earthquake Data List: View a list of recent earthquakes with details like magnitude and location.
Map Integration: Visualize earthquake locations on a map.
Reactive Programming: Utilizes Combine for managing asynchronous data.


**Programmatic UI:** Built entirely with programmatic UI without using Storyboard.
MVVM Architecture: Separates concerns effectively using the MVVM pattern.
Architecture

The project follows the MVVM (Model-View-ViewModel) architecture:

Model: Represents the data layer, including data from the USGS API.
View: Handles UI elements and user interaction.
ViewModel: Acts as an intermediary between the Model and the View, fetching and processing data to be displayed.
Design Decisions
Combine: Chosen for its native integration with Swift to handle asynchronous tasks and data binding.
Programmatic UI: Facilitates more control and flexibility over the user interface, and aligns with the project requirement to avoid Storyboards.
MKMapView: Used to integrate map functionalities, showing earthquake locations in a geographical context.
Setup

Prerequisites
Xcode 12 or later
iOS 14.0 or later
Installation

Clone the repository:
bash
Copy code
git clone https://github.com/victorkibichy/EarthquakeMonitor.git

Navigate to the project directory:
bash
Copy code
cd EarthquakeMonitor

Select the target device and click the run button in Xcode.
Usage

**Launchscreen**
![Simulator Screenshot - iPhone 14 Pro Max - 2024-06-14 at 11 24 32](https://github.com/victorkibichy/EarthquakeMonitor/assets/155962239/e85f6f44-0b86-4ba5-bd7b-69f1a37e312e)


**Earthquake List:**
![Simulator Screenshot - iPhone 14 Pro Max - 2024-06-14 at 11 24 10](https://github.com/victorkibichy/EarthquakeMonitor/assets/155962239/25cc1475-6dcc-404d-b7e6-71a9473c24f4)



The main screen displays a list of recent earthquakes.
Each cell shows the magnitude (in red) and location (in blue) of the earthquake.
**Map View:
**
![Simulator Screenshot - iPhone 14 Pro Max - 2024-06-14 at 11 24 15](https://github.com/victorkibichy/EarthquakeMonitor/assets/155962239/dc48a760-faac-489b-85b8-7854e338c3f4)

**UPDATED MAP WITH annotations **

![Simulator Screenshot - iPhone 14 Pro - 2024-06-14 at 12 23 59](https://github.com/victorkibichy/EarthquakeMonitor/assets/155962239/046bc57c-767b-44c4-99e0-fc97a0cc5000)



Switch to the map view using the tab bar.
The map shows pins at the locations of recent earthquakes.
Refreshing Data:

The app fetches the latest earthquake data when launched.
Screenshots

Earthquake List:
Map View:
Project Structure

markdown
Copy code
EarthquakeMonitor/
│
├── Model/
│   ├── Earthquake.swift
│   ├── EarthquakeResponse.swift
│   └── ErrorMessages.swift
│
├── View/
│   ├── EarthquakeViewController.swift
│   ├── MapViewController.swift
│   └── MainTabBarController.swift
│
├── ViewModel/
│   └── EarthquakeViewModel.swift
│
└── Resources/
    └── Assets.xcassets
Dependencies

Combine: Used for reactive programming and handling asynchronous tasks.
MapKit: For map functionalities and displaying earthquake locations.
Security



