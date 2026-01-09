# SAS Clinical Acceleration Repository - REST API Call Examples

## Overview

Included are SAS Macros that enable you to execute REST API Calls to the SAS Clinical Acceleration Repository. The instructions for each macro are included in the header section of each program.
<!--
-->

### What's New
Version 1.0 - Released the initial set of macros on December 5, 2025
<!--
-->

### Prerequisites
You need a SAS instance (SAS 9, SAS Viya, SAS Viya Workbench, SAS APRO) to execute the SAS Code
<!--
-->

## Installation
Download the macros and include them in your SAS process
<!--
-->

### Getting Started
Place the macros to your global macro library and include them before executing your SAS programs.
<!--
-->

### Running
The macro calls can be included in your SAS Code
<!--
-->

### Examples

Example Call :

%CAR_Get_Access_Token (url=&url, usr=&userid, pw=&userpw);
<!--
-->

### Troubleshooting
Please contact the site owner, if you run into any issues when executing this SAS Code
<!--
-->

## Contributing
Daniel Christen - SAS
Kim Peplinski - SAS
Matt Becker - SAS
<!--
-->

Maintainers are accepting patches and contributions to this project.
Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details about submitting contributions to this project.

## License

This project is licensed under the [Apache 2.0 License](LICENSE).

## Additional Resources
Detailed descriptions are included in the macro headers
<!--
-->

* [Upload repository content (SAS Developers](https://developer.sas.com/rest-apis/clinicalRepository/putRepositoryItemContent)

