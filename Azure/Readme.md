# Add users to an MFA Pilot Group

Define your group names.  
Staff will only target users in the staff group.  
2fa was an existing 2FA group that does not need added to the new one.  
MFAPilot is the new group we add users to who have signed up for MFA.  

Setup conditional access policies to enforce MFA on the pilot group.  

If the user has the Microsoft Authenticator app OR a FIDO key they get added to the MFAPilot group for MFA to be enforced.  

# Setup
Add or modify the connect lines to connect to both Connect-AzureAD and Connect-MsolService

Modify the report line with your email information.  

Modify the username = line with your upn.  Currently line 76

Schedule to run and as users sign up, they will have MFA enforced.  