# Attendance Android App Requirements
1.	The system must provide sign-up and sign-in functionality and proper Authentication system. 
2.	The system must provide helpful error messages that instruct the user on what to do.
3.	The system shall have good color contrast and easy to use for various phone resolutions and users.
4.	The system must provide a student with the ability to register in one or more courses/subjects in his department.
5.	The system must provide a student with the ability to view his/her attendance history.
6.	The system must provide a teacher dashboard where a teacher can create subjects/courses he/she offers in different Departments.
7.	The system must keep track of all the sessions within a subject, and the teacher can create sessions.
8.	The system must show the students registered in a subject, and the teacher will mark them present or absent and save and see the summary of the session later.
9.	The system should run on 32-bit and 64-bit ARM Android phones.

# User Stories
1.	As a Teacher, I want an easy-to-use responsive interface. I want to log in using email so that I can create subjects and access my assigned courses. I want to be able to easily view the attendance list of students. And I have the ability to create a subject and, within a subject, multiple sessions, and the attendance history will be saved.
2.	As a student, I want information about courses to be easily accessible from the interface. I want an easy login feature. I want to register on the courses I want and see my attendance history.
Description
The AttendLite is a mobile application developed using Flutter and Firebase that simplifies attendance management in educational institutions. Users can log in with their email addresses and are redirected to specific pages based on their roles—students or teachers. Here we subjects are similar to courses and sessions are similar to classes.

# Main Functionality
## Authentication
Firebase Authentication handles user sign-up and sign-in. The application supports email-based authentication.
Student Portal
Students can register for courses that teachers offer in their department. They can view attendance for a subject and which sessions they attended or did not.

## Teacher Portal
Instructors can create subjects/courses for a specific department. They can start a session where students registered for this subject will appear in a sorted way. The teacher marks them present/absent and saves. They can also inspect attendance records to see which students have attended the individual session.

## Tech Stack

### Technology	Usage
Flutter-	Mobile application development

Dart -Programming language


Firebase -Authentication	User authentication

Cloud Firestore-	Database

Git & GitHub-	Version control


## Backend Database description
The database used is Firebase, which is a no-SQL database that organizes data into documents and collections. The data is saved as key-value pairs. There are 5 collections: users (student and teacher), subjects, registrations, sessions, attendance. Each collection has some key-value pair data. The data is fetched from the backend to the application by Firestore queries.



## Screen Description
1.	Registration:  User login for the first time It is for authentication as our requirement. One can’t register twitch with the same email. 

2.	Email Verification: Email verification added as for authentication everyone can register with their own email.  
3.	Login:  Student and Teacher login with their email and password the app detect the user teacher or student by fetching data from backend and move to their homescreen. 
4.	Teacher Home Screen: The teacher will see the whole list of subjects he offers in many departments. And he/she can add a new subject if he wanted.

 


5.	Adding Subject: Teacher add a subject with entering the name and selecting a department.
  
6.	Sessions: After clicking on a subject teacher will see the list of sessions has been taken. By clicking on starting button, he can start a session there is also a popup to confirm starting the session. By clicking on a session, the teacher can see session summary. The session sorted by their taking time old sessions come first.

 
7.	Attendance: All the students that registered in this subject will appear in a sorted way by their roll and the teacher mark the present or absent by clicking on each and if all students are marked then the teacher can save attendance unless their will be a snackbar that told “please mark all students”.
  
8.	Session Summary: This is the page that records the session history which one was a major requirement. This records how many students were present and who was present or absent by their name and roll.
 
 
9.	Student Home: Students will only see the subjects that belongs to his department. Here he can see the teacher’s name and teacher department to ensure one enroll to the right subject. Here first the teacher creates the subjects then it will show to the students. Then the students can register in the subjects they want and it will store and show the teacher when the teacher take attendance. By clicking on view the students also see their attendance summary in a subject which was another major requirement. 
 
10.	Attendance Summary: The student can see the total sessions has been taken and how many sessions he attended, also can see which day he was present or absent.
 


