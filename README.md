# IRIS_2023_Akshat_231CS110

App Project for IRIS Recruitment - Task : Mess Management application

## To make things easy
- Demo video : https://youtu.be/aFSQ0eiICdw

## To access app (Added on 15 jan) 
- Login credentials of admin:
- email: admin@gmail.com
- password: Admin@123
- After that you can create a new account and proceed.


## Technologies Used
- Flutter
- Dart
- Firebase
- Hive

## List of Implemented Features

### Login and Registration: 

- User/Admin login/logout and User Registration using Firebase: Implemented using the Firebase Authentication API. The app handles API responses related to incorrect passwords, invalid emails, weak passwords etc.
- Implemented Auto-Login: The user doesn't need to authenticate everytime the app is restarted. Their authentication state is checked by accessing the login status from Hive and they are auto-logged in.
- On login, it automatically detects if the user is a student or admin and goes to the respective page. The admin has an option to create a new user (Student/Admin).

### User Dashboard:
- Implemented a User Dashboard displaying name, email, roll number, mess balance and current mess information (displayed after initial mess registration).
- The user can top up their mess balance through Add Mess Balance. 
- The user can register for a mess using mess registration. If their status is Not Allotted. During registration, they can view all necessary details like vacancy, Block number, mess councillor and his/her email ID and contact number.
- The user can then initiate a mess change request that goes to the admin. They can view all necessary details like vacancy, Block number, mess councillor and his/her email ID and contact number.
- The user can view the mess costs for a day (Breakfast, Lunch, Snacks, Dinner along with the total cost).
- The user can apply for leaves during which the mess balance is not deducted.
- The user has an option to send feedback to the admin.
- At last, there is a logout button to go back to the sign in page. During the process, the Hive data is cleared to preventt he leakage of the users data.

### Admin Page
- Manage Messes: Admins have the authority to create and delete messes. They can create a new mess with all necessary details. Setting the total number of seats in each mess is also within their control. There is a drop down button to select a mess and delete it. If a mess is deleted, the users in that mess are automatically deallocated.
- Mess Change Requests: They can approve/reject mess change requests from users. They can view the requests initiated by users. They have the option to Approve or Reject these requests. On approval, the mess of the user and the mess occupancy is adjusted accordingly.
- Allocate/Deallocate Users: Admins can individually deallocate or reallocate users. They have the option to allocate users into any mess(Also checks the vacancy in the mess) and deallocate users. The mess vacancies are adjusted accordingly.
- Create new account: The admin can create a new user based on the role of a student or admin. If a student is created, the roll number is required additionally along with name, email and password. The authentication details are then updated on Firebase.
- Update mess costs: The admin can approve the costs of meals per day - Breakfast, Lunch, Snacks and Dinner.
- Feedback: The admin can view the feedback sent by the students for improving messes.
- Logout: To go back to the sign in page. During the process, the Hive data is cleared to preventt the leakage of the data.

### Deduction of mess balance
- The mess balance is deducted automatically for all users when the app is started before proceeding to the sign in screen.
- The app checks the last deducted date from Firebase. Based on the difference between the last deducted date and the current date, mess balance is deducted for each user. During the process, if the user was on leaves in the duration, the balance is not deducted for those specific days.
- The last deducted date is updated on Firebase.
- If the user's mess is unallotted, the mess blaance is not deducted.
- An Important feature: If the mess balance goes below -500, the user's mess is deallotted.

### Mess Change Request Flow
- Users initiate a mess change request.
- Users are shown approval states such as "In Progress" or "Approved" to track their request status.
- Upon approval, the user's mess information in the application is updated accordingly.
- All leaves are automatically approved. Admin intervention isn’t required.
- AFter Approved/Rejected, the user can initiate another request.

### Local Storage using Hive and Realtime Database using Firebase:
- Everytime the user signs into his account, data is loaded from Realtime Firebase Database into Hive.
-  On signing out of the account, all the data from Hive is backed up to Firebase and the local storage (Hive) is cleared.
-  Clearing Hive prevents the leakage of the prior users data into the account of the newly logged in user from the same device.
-  Accessing Firebase during login to retrieve data and then switching to Hive for most of the other operations improves performance.

## List of Planned Features
- Utilize Firebase Cloud Messaging (FCM) for notifications when a user’s mess balance is insufficient.
- Optimizing the UI to ensure a seamless experience on both Android and iOS devices.

## List of known Bugs
- The UI may not scale appropriately in some devices.

## Operating System Used for Development: 
- Windows 11

## References:
- Flutter docs: https://docs.flutter.dev/
- Hive docs: https://docs.hivedb.dev/#/
- Dart docs: https://dart.dev/guides
- Firebase docs: https://firebase.google.com/docs
- Flutter packages: https://pub.dev/
- Git cheat sheet: https://education.github.com/git-cheat-sheet-education.pdf
- Flutter Bootcamp 2022-23: https://www.youtube.com/@irisnitksurathkal537
