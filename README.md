# NexusFileApp

A specialized iOS application for agricultural crop solution salespeople to manage spray programs and product information for their clients. Built with SwiftUI following Apple's best practices.

## Features

### Core Functionality
- 🚜 **Spray Program Management**: Create and manage tractor calibration programs for clients
- 📁 **Document Organization**: Organize product labels, safety data, and technical information
- 📱 **Modern UI**: Built with SwiftUI for a native iOS experience

- 📤 **Share Extension**: Import files from other apps
- 🎯 **File Preview**: Preview PDFs, images, and documents
- 📊 **Export Support**: Export spray programs as Excel or PDF
- 🔍 **Search**: Find files quickly with intelligent search
- 📋 **Context Menus**: Rich context menus for file operations

### Technical Excellence
- ✅ **Error Handling**: Comprehensive error handling with user-friendly messages
- ✅ **Loading States**: Proper loading indicators and empty states
- ✅ **Accessibility**: Full VoiceOver support and accessibility features
- ✅ **Performance**: Optimized with caching and async operations
- ✅ **Testing**: Comprehensive unit tests
- ✅ **Logging**: Structured logging for debugging
- ✅ **Memory Management**: Proper memory management and cleanup

## Architecture

### MVVM Pattern
The app follows the Model-View-ViewModel pattern:
- **Models**: `DirectoryItem`, `AppError`
- **Views**: SwiftUI views with clear separation of concerns
- **ViewModels**: `FileManagerService` handles business logic

### Key Components

#### Services
- `FileManagerService`: Core file operations with error handling
- `SharedFileManager`: Shared file access for app and extensions
- `FileCache`: Performance optimization through caching
- `Haptics`: Consistent haptic feedback

#### Views
- `HomeView`: Main categories view
- `FolderView`: File browser with search and sorting
- `LoadingView`, `ErrorView`, `EmptyStateView`: Reusable UI components

#### Models
- `DirectoryItem`: Enhanced file model with metadata
- `AppError`: Centralized error handling

## Best Practices Implemented

### 1. Error Handling
- Centralized error model (`AppError`)
- User-friendly error messages with recovery suggestions
- Proper error propagation through the app
- Graceful degradation when operations fail

### 2. Performance
- Async file operations to prevent UI blocking
- File metadata caching to reduce filesystem calls
- Lazy loading of file lists
- Efficient sorting and filtering

### 3. User Experience
- Loading states for all async operations
- Empty states with helpful guidance
- Consistent haptic feedback
- Smooth animations and transitions
- Search functionality with real-time filtering

### 4. Accessibility
- VoiceOver support for all interactive elements
- Proper accessibility labels and hints
- Semantic grouping of related elements
- Support for Dynamic Type

### 5. Security
- Proper file permissions handling
- Secure file operations with error checking
- Input validation and sanitization
- Safe file import/export operations

### 6. Testing
- Comprehensive unit tests for core functionality
- Test coverage for file operations
- Error condition testing
- Performance testing

### 7. Logging
- Structured logging with os.log
- Different log levels for different environments
- Performance monitoring
- Error tracking and debugging

## File Support

The app supports various file types:
- **PDF Documents**: Full preview and sharing
- **Excel Spreadsheets**: View, edit, and export as PDF
- **Word Documents**: View and edit support
- **Images**: JPEG, PNG, HEIC formats
- **Text Files**: Plain text and RTF documents



## Share Extension

The app includes a share extension that allows:
- Importing files from other apps
- Quick file organization
- Batch file operations
- Direct file access from other apps

## Development Guidelines

### Code Style
- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comprehensive documentation
- Implement proper error handling

### Testing
- Write tests for all business logic
- Test error conditions
- Test performance with large file sets
- Test accessibility features

### Performance
- Use async operations for file I/O
- Implement caching for frequently accessed data
- Optimize UI updates
- Monitor memory usage

### Security
- Validate all user inputs
- Handle file permissions properly
- Secure file operations
- Protect user data

## Building and Running

1. Open `NexusFileApp.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project
4. The app will create default categories on first launch

## Testing

Run the test suite:
```bash
# Run all tests
xcodebuild test -project NexusFileApp.xcodeproj -scheme NexusFileApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test target
xcodebuild test -project NexusFileApp.xcodeproj -scheme NexusFileApp -only-testing:NexusFileAppTests/FileManagerServiceTests
```

## Contributing

When contributing to this project:

1. Follow the existing code style
2. Add tests for new functionality
3. Update documentation
4. Test on different devices and iOS versions
5. Ensure accessibility compliance

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions:
- Check the documentation
- Review the test cases for usage examples
- Examine the source code for implementation details
