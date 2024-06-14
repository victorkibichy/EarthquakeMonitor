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

**Earthquake List:**

The main screen displays a list of recent earthquakes.
Each cell shows the magnitude (in red) and location (in blue) of the earthquake.
Map View:

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

API Security: No API keys are used in this project. However, ensure any sensitive information is securely managed if required.
Networking: All network requests use HTTPS to ensure data security and integrity.
Testing

Unit Testing: Implement tests for ViewModel logic to ensure correct data processing.
UI Testing: Use XCUITest to verify the UI components function as expected.
