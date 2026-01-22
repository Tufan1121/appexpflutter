# appexpflutter_update

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

//rootProject.buildDir = '../build'
subprojects {
    //project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    tasks.whenTaskAdded { task ->
        if (task.name.contains('generateDebugUnitTestConfig') ||
                task.name.contains('generateReleaseUnitTestConfig') ||
                task.name.contains('generateSafeArgs')) {
            task.enabled = false
        }
    }
}
tasks.register("clean", Delete) {
    delete rootProject.layout.buildDirectory
}


