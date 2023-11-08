Install-Module Microsoft.Graph
Connect-MgGraph -Scopes AppRoleAssignment.ReadWrite.All,Application.Read.All

$GraphAppId = "00000003-0000-0000-c000-000000000000" # Microsoft Graph AppId
$ManagedIdentityName = '' #Your Managed Identity Name
$ManagedIdentity = Get-AzADServicePrincipal -Filter "displayName eq '$ManagedIdentityName'"
$GraphSpn = Get-AzADServicePrincipal -Filter "appId eq '$GraphAppId'"

#Permission Name You Want to Assign
$GraphPermissions = @( 
  "Directory.Read.All"
  "User.Read.All"
  )

# Get Graph App Roles for the permission you want to assign
$AppRoles = $GraphSpn.AppRole | Where-Object {($_.Value -in $GraphPermissions) -and ($_.AllowedMemberType -contains "Application")}

foreach($AppRole in $AppRoles){
  $AppRoleAssignment = @{
    "PrincipalId" = $ManagedIdentity.Id
    "ResourceId" = $GraphSpn.Id
    "AppRoleId" = $AppRole.Id
  }

  New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $AppRoleAssignment.PrincipalId -BodyParameter $AppRoleAssignment
}

