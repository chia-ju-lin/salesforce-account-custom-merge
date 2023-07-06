# Purpose of the Project: 

The functionality is similar to the standard salesfoce merge function.
This project provids the following functionality.
- UI to allow two manual input for the account IDs
- Display all fieds which have differnt values between the two accouts for the selection
*Please not that all Date, DateTime and not editable fields are not displaied


## Child Object Customization

Modify the code under force-app/main/default/classes/AccountMergeController.cls 
-specify the child object
-specify the exernal ID
![Alt text](image-1.png)
![Alt text](image.png)

## Disable Merge Conditon Customization

Modify the code under force-app/main/default/classes/AccountMergeController.cls
![Alt text](image-2.png)

## Read All About It
