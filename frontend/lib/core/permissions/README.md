# Role-Based Permission System

This directory contains the role-based access control (RBAC) system for the Smart Coach application.

## Architecture

The permission system is built using the BLoC pattern and provides a scalable way to manage user permissions throughout the app.

### Components

1. **permission_constants.dart** - Defines all permission strings and role IDs
2. **role_permissions.dart** - Maps roles to their permissions
3. **bloc/permission_bloc.dart** - Manages permission state
4. **bloc/permission_state.dart** - Permission state model
5. **bloc/permission_event.dart** - Permission events
6. **permission_helper.dart** - Helper widgets and extensions for easy permission checking

## Roles

Currently supported roles:

- **Master (role_id: 1)** - Full access to all features
- **Super Admin (role_id: 2)** - Administrative access without user registration
- **Regional Master (role_id: 3)** - Read access to configurations and reports
- **Train Operator (role_id: 4)** - Limited access to own train reports

## Usage

### 1. Using PermissionGuard Widget

Wrap any widget to show/hide based on permissions:

```dart
PermissionGuard(
  permission: PermissionConstants.canViewUserRegistration,
  child: _drawerItem('User Registration', onTap: () {...}),
)
```

### 2. Using Role-Based Guard

```dart
PermissionGuard(
  roleId: RoleIds.master,
  child: Text('Master only content'),
)
```

### 3. Using Multiple Permissions

```dart
PermissionGuard(
  permissions: [
    PermissionConstants.canViewReports,
    PermissionConstants.canExportReports,
  ],
  requireAll: false, // User needs ANY of these permissions
  child: Text('Reports section'),
)
```

### 4. Using Context Extension

```dart
if (context.hasPermission(PermissionConstants.canApproveUsers)) {
  // Show approve button
}

if (context.hasRole(RoleIds.master)) {
  // Master-only logic
}
```

### 5. Using BLoC Directly

```dart
final permissionBloc = context.read<PermissionBloc>();

if (permissionBloc.hasPermission(PermissionConstants.canEditUsers)) {
  // Edit user logic
}
```

## Adding New Permissions

### Step 1: Add Permission Constant

In `permission_constants.dart`:

```dart
static const String canViewNewFeature = 'can_view_new_feature';
```

### Step 2: Add Permission to Roles

In `role_permissions.dart`, add the permission to appropriate role sets:

```dart
static final Set<String> _masterPermissions = {
  // ...existing permissions
  PermissionConstants.canViewNewFeature,
};
```

### Step 3: Use in UI

```dart
PermissionGuard(
  permission: PermissionConstants.canViewNewFeature,
  child: NewFeatureWidget(),
)
```

## How It Works

1. **Login**: When user logs in, `LoginBloc` initializes permissions based on user's `role_id`
2. **Profile Load**: When profile is fetched, `ProfileBloc` updates permissions
3. **Logout**: Permissions are cleared when user logs out
4. **UI**: Components use `PermissionGuard` or context extensions to check permissions

## Integration Points

- **LoginBloc**: Initializes permissions on successful login
- **ProfileBloc**: Updates permissions when profile is loaded, clears on logout
- **PermissionBloc**: Singleton instance provided at app root level in main.dart

## Examples

### Hide User Management Section for Non-Master Users

```dart
PermissionGuard(
  roleId: RoleIds.master,
  child: _drawerSection(
    title: 'User Management',
    children: [...],
  ),
)
```

### Show Different Content Based on Role

```dart
BlocBuilder<PermissionBloc, PermissionState>(
  builder: (context, state) {
    if (state.roleId == RoleIds.trainOperator) {
      return TrainOperatorDashboard();
    } else if (state.roleId == RoleIds.master) {
      return MasterDashboard();
    }
    return DefaultDashboard();
  },
)
```

### Conditional Navigation

```dart
if (context.hasPermission(PermissionConstants.canViewUserRegistration)) {
  context.push(AppRouter.registerRoute);
} else {
  showUnauthorizedDialog();
}
```

## Best Practices

1. **Always use PermissionGuard for UI visibility** - Don't manually check permissions for hiding/showing widgets
2. **Use descriptive permission names** - Make it clear what the permission allows
3. **Group related permissions** - Keep configuration permissions together
4. **Document new permissions** - Update this README when adding new permissions
5. **Test with different roles** - Ensure features work correctly for all roles
