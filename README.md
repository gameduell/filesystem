## Description

This library provides asset packaging and runtime loading API for iOS, Android, HTML5 and Flash. It provides a XML configuration plugin that lets you configure asset folders to included in the final Application. It also provides a Asset processing API in the duell tool plugin, that lets other libraries process the assets before they are copied to the final app, e.g. Atlas packing, WebP compression.

## Usage:

Register an Asset folder in your project xml file with something like:

	<library-config>
		<filesystem>
			<static-assets path="Assets" />
		</filesystem>
	</library-config>

Access them by using the FileSystem class API.

## Release Log

### 4.0.0

New duell tool version compatibility

### 3.0.0

New duell tool version compatibility

### 2.0.0

Removed file seeking API as that is not easy to make cross platform

### 1.0.0

Initial release
