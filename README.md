# Salesforce DX Sample Project

This is a sample Salesforce DX project that demonstrates a basic project structure with custom objects and Apex classes.

## Project Structure

```
force-app/
└── main
    └── default
        ├── classes/
        │   ├── AccountService.cls
        │   └── AccountServiceTest.cls
        └── objects/
            └── Project__c/
                ├── fields/
                │   ├── Description__c.field-meta.xml
                │   ├── Status__c.field-meta.xml
                │   └── Start_Date__c.field-meta.xml
                └── Project__c.object-meta.xml
```

## Components

### Apex Classes
- **AccountService**: Provides methods for Account operations
  - `updateAccountsRevenue`: Updates annual revenue for multiple accounts
  - `createAccount`: Creates a new account with default values

### Custom Object
- **Project__c**: A custom object for project management
  - Standard Fields: Name
  - Custom Fields:
    - Description (Long Text Area)
    - Status (Picklist: Not Started, In Progress, On Hold, Completed, Cancelled)
    - Start Date (Date)

## Getting Started

1. Clone the repository
2. Authenticate with your Dev Hub:
   ```bash
   sfdx auth:web:login -d -a devhub
   ```
3. Create a new scratch org:
   ```bash
   sfdx force:org:create -s -f config/project-scratch-def.json -a my-scratch-org
   ```
4. Push source to the scratch org:
   ```bash
   sfdx force:source:push
   ```
5. Open the scratch org:
   ```bash
   sfdx force:org:open
   ```

## Running Tests

To run all tests:
```bash
sfdx force:apex:test:run -c -r human -w 10
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
