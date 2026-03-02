## ADDED Requirements

### Requirement: Command field full width

Approval card SHALL display the command field with full width for better readability.

#### Scenario: Command takes full width
- **WHEN** rendering approval card
- **THEN** the command field SHALL have `is_short: false`
- **AND** the command field SHALL occupy the entire row

### Requirement: Field icons

Approval card SHALL display icons for each field to enable quick visual scanning.

#### Scenario: Command field icon
- **WHEN** displaying command field
- **THEN** the label SHALL include ⌨️ icon prefix

#### Scenario: Directory field icon
- **WHEN** displaying directory field
- **THEN** the label SHALL include 📁 icon prefix

#### Scenario: Request ID field icon
- **WHEN** displaying request ID field
- **THEN** the label SHALL include 🔗 icon prefix

### Requirement: Two-column layout for secondary fields

Secondary fields (directory, request ID) SHALL share a row in two-column layout.

#### Scenario: Directory and request ID share row
- **WHEN** rendering approval card
- **THEN** directory and request ID fields SHALL have `is_short: true`
- **AND** they SHALL be displayed side by side

### Requirement: Consistent layout across card types

All card types (approval request, approval result, timeout notification) SHALL use consistent field layout.

#### Scenario: Approval result card uses same layout
- **WHEN** displaying approval result (approved/denied/timeout)
- **THEN** command field SHALL have `is_short: false`
- **AND** secondary fields SHALL have `is_short: true`

### Requirement: Result cards show directory

Approval result cards SHALL display directory field for context.

#### Scenario: Approved card shows directory
- **WHEN** displaying approved result card
- **THEN** the card SHALL include directory field with 📁 icon

#### Scenario: Denied card shows directory
- **WHEN** displaying denied result card
- **THEN** the card SHALL include directory field with 📁 icon

#### Scenario: Timeout card shows directory
- **WHEN** displaying timeout result card
- **THEN** the card SHALL include directory field with 📁 icon
