# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

#### Public Classes

* [`archive`](#archive): Manages archive module's dependencies.
* [`archive::staging`](#archivestaging): Backwards-compatibility class for staging module

#### Private Classes

* `archive::params`: OS specific `archive` settings such as default user and file mode.

### Defined types

* [`archive::artifactory`](#archiveartifactory): Archive wrapper for downloading files from artifactory
* [`archive::download`](#archivedownload): Archive downloader with integrity verification
* [`archive::go`](#archivego): download from go
* [`archive::nexus`](#archivenexus): define: archive::nexus ======================  archive wrapper for downloading files from Nexus using REST API. Nexus API: https://repository

### Resource types

* [`archive`](#archive): Manage archive file download, extraction, and cleanup.

### Functions

#### Public Functions

* [`archive::artifactory_checksum`](#archiveartifactory_checksum): A function that returns the checksum value of an artifact stored in Artifactory
* [`archive::artifactory_latest_url`](#archiveartifactory_latest_url)
* [`archive::parse_artifactory_url`](#archiveparse_artifactory_url): A function to parse an Artifactory maven 2 repository URL

#### Private Functions

* `archive::assemble_nexus_url`: Assembles a complete nexus URL from the base url and query parameters
* `archive::go_md5`: Retrieves and returns specific file's md5 from GoCD server md5 checksum file

## Classes

### <a name="archive"></a>`archive`

Manages archive module's dependencies.

#### Examples

##### On Windows, ensure 7zip is installed using the default `chocolatey` provider.

```puppet
include archive
```

##### On Windows, install a 7zip MSI with the native `windows` package provider.

```puppet
class { 'archive':
  seven_zip_name     => '7-Zip 9.20 (x64 edition)',
  seven_zip_source   => 'C:/Windows/Temp/7z920-x64.msi',
  seven_zip_provider => 'windows',
}
```

##### Install the AWS CLI tool. (Not supported on Windows).

```puppet
class { 'archive':
  aws_cli_install => true,
}
```

##### Deploy a specific archive

```puppet
class { 'archive':
  archives => { '/tmp/jta-1.1.jar' => {
                  'ensure' => 'present',
                  'source'  => 'http://central.maven.org/maven2/javax/transaction/jta/1.1/jta-1.1.jar',
                  }, }
}
```

#### Parameters

The following parameters are available in the `archive` class:

* [`seven_zip_name`](#seven_zip_name)
* [`seven_zip_provider`](#seven_zip_provider)
* [`seven_zip_source`](#seven_zip_source)
* [`aws_cli_install`](#aws_cli_install)
* [`gsutil_install`](#gsutil_install)
* [`archives`](#archives)

##### <a name="seven_zip_name"></a>`seven_zip_name`

Data type: `Optional[String[1]]`

7zip package name.  This parameter only applies to Windows.

Default value: `$archive::params::seven_zip_name`

##### <a name="seven_zip_provider"></a>`seven_zip_provider`

Data type: `Optional[Enum['chocolatey','windows','']]`

7zip package provider.  This parameter only applies to Windows where it defaults to `chocolatey`. Can be set to an empty string, (or `undef` via hiera), if you don't want this module to manage 7zip.

Default value: `$archive::params::seven_zip_provider`

##### <a name="seven_zip_source"></a>`seven_zip_source`

Data type: `Optional[String[1]]`

Alternative package source for 7zip.  This parameter only applies to Windows.

Default value: ``undef``

##### <a name="aws_cli_install"></a>`aws_cli_install`

Data type: `Boolean`

Installs the AWS CLI command needed for downloading from S3 buckets.  This parameter is currently not implemented on Windows.

Default value: ``false``

##### <a name="gsutil_install"></a>`gsutil_install`

Data type: `Boolean`

Installs the GSUtil CLI command needed for downloading from GS buckets.  This parameter is currently not implemented on Windows.

Default value: ``false``

##### <a name="archives"></a>`archives`

Data type: `Hash`

A hash of archive resources this module should create.

Default value: `{}`

### <a name="archivestaging"></a>`archive::staging`

Backwards-compatibility class for staging module

#### Parameters

The following parameters are available in the `archive::staging` class:

* [`path`](#path)
* [`owner`](#owner)
* [`group`](#group)
* [`mode`](#mode)

##### <a name="path"></a>`path`

Data type: `String`

Absolute path of staging directory to create

Default value: `$archive::params::path`

##### <a name="owner"></a>`owner`

Data type: `String`

Username of directory owner

Default value: `$archive::params::owner`

##### <a name="group"></a>`group`

Data type: `String`

Group of directory owner

Default value: `$archive::params::group`

##### <a name="mode"></a>`mode`

Data type: `String`

Mode (permissions) on staging directory

Default value: `$archive::params::mode`

## Defined types

### <a name="archiveartifactory"></a>`archive::artifactory`

Archive wrapper for downloading files from artifactory

#### Examples

##### 

```puppet
archive::artifactory { '/tmp/logo.png':
  url   => 'https://repo.jfrog.org/artifactory/distributions/images/Artifactory_120x75.png',
  owner => 'root',
  group => 'root',
  mode  => '0644',
}
```

##### 

```puppet
$dirname = 'gradle-1.0-milestone-4-20110723151213+0300'
$filename = "${dirname}-bin.zip"

archive::artifactory { $filename:
  archive_path => '/tmp',
  url          => "http://repo.jfrog.org/artifactory/distributions/org/gradle/${filename}",
  extract      => true,
  extract_path => '/opt',
  creates      => "/opt/${dirname}",
  cleanup      => true,
}
```

#### Parameters

The following parameters are available in the `archive::artifactory` defined type:

* [`url`](#url)
* [`headers`](#headers)
* [`path`](#path)
* [`ensure`](#ensure)
* [`cleanup`](#cleanup)
* [`extract`](#extract)
* [`archive_path`](#archive_path)
* [`creates`](#creates)
* [`extract_path`](#extract_path)
* [`group`](#group)
* [`mode`](#mode)
* [`owner`](#owner)
* [`password`](#password)
* [`username`](#username)

##### <a name="url"></a>`url`

Data type: `Stdlib::HTTPUrl`

artifactory download URL

##### <a name="headers"></a>`headers`

Data type: `Array`

HTTP header(s) to pass to source

Default value: `[]`

##### <a name="path"></a>`path`

Data type: `String`

absolute path for the download file (or use archive_path and only supply filename)

Default value: `$name`

##### <a name="ensure"></a>`ensure`

Data type: `Enum['present', 'absent']`

ensure download file present/absent

Default value: `'present'`

##### <a name="cleanup"></a>`cleanup`

Data type: `Boolean`

remove archive after file extraction

Default value: ``false``

##### <a name="extract"></a>`extract`

Data type: `Boolean`

whether to extract the files

Default value: ``false``

##### <a name="archive_path"></a>`archive_path`

Data type: `Optional[Stdlib::Absolutepath]`

parent directory to download archive into

Default value: ``undef``

##### <a name="creates"></a>`creates`

Data type: `Optional[String]`

the file created when the archive is extracted

Default value: ``undef``

##### <a name="extract_path"></a>`extract_path`

Data type: `Optional[String]`

absolute path to extract archive into

Default value: ``undef``

##### <a name="group"></a>`group`

Data type: `Optional[String]`

file group (see archive params for defaults)

Default value: ``undef``

##### <a name="mode"></a>`mode`

Data type: `Optional[String]`

file mode (see archive params for defaults)

Default value: ``undef``

##### <a name="owner"></a>`owner`

Data type: `Optional[String]`

file owner (see archive params for defaults)

Default value: ``undef``

##### <a name="password"></a>`password`

Data type: `Optional[String]`

Password to authenticate with

Default value: ``undef``

##### <a name="username"></a>`username`

Data type: `Optional[String]`

User to authenticate as

Default value: ``undef``

### <a name="archivedownload"></a>`archive::download`

Archive downloader with integrity verification

#### Examples

##### 

```puppet
archive::download {"apache-tomcat-6.0.26.tar.gz":
  ensure => present,
  url    => "http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.26/bin/apache-tomcat-6.0.26.tar.gz",
}
```

##### 

```puppet
archive::download {"apache-tomcat-6.0.26.tar.gz":
  ensure        => present,
  digest_string => "f9eafa9bfd620324d1270ae8f09a8c89",
  url           => "http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.26/bin/apache-tomcat-6.0.26.tar.gz",
}
```

#### Parameters

The following parameters are available in the `archive::download` defined type:

* [`url`](#url)
* [`headers`](#headers)
* [`allow_insecure`](#allow_insecure)
* [`checksum`](#checksum)
* [`digest_type`](#digest_type)
* [`ensure`](#ensure)
* [`src_target`](#src_target)
* [`digest_string`](#digest_string)
* [`digest_url`](#digest_url)
* [`proxy_server`](#proxy_server)
* [`user`](#user)

##### <a name="url"></a>`url`

Data type: `String`

source

##### <a name="headers"></a>`headers`

Data type: `Array`

HTTP (s) to pass to source

Default value: `[]`

##### <a name="allow_insecure"></a>`allow_insecure`

Data type: `Boolean`

Allow self-signed certificate on source?

Default value: ``false``

##### <a name="checksum"></a>`checksum`

Data type: `Boolean`

Should checksum be validated?

Default value: ``true``

##### <a name="digest_type"></a>`digest_type`

Data type: `Enum['none', 'md5', 'sha1', 'sha2','sha256', 'sha384', 'sha512']`

Digest to use for calculating checksum

Default value: `'md5'`

##### <a name="ensure"></a>`ensure`

Data type: `Enum['present', 'absent']`

ensure file present/absent

Default value: `'present'`

##### <a name="src_target"></a>`src_target`

Data type: `Stdlib::Compat::Absolute_path`

Absolute path to staging location

Default value: `'/usr/src'`

##### <a name="digest_string"></a>`digest_string`

Data type: `Optional[String]`

Value  expected checksum

Default value: ``undef``

##### <a name="digest_url"></a>`digest_url`

Data type: `Optional[String]`

URL  expected checksum value

Default value: ``undef``

##### <a name="proxy_server"></a>`proxy_server`

Data type: `Optional[String]`

FQDN of proxy server

Default value: ``undef``

##### <a name="user"></a>`user`

Data type: `Optional[String]`

User used to download the archive

Default value: ``undef``

### <a name="archivego"></a>`archive::go`

download from go

#### Parameters

The following parameters are available in the `archive::go` defined type:

* [`server`](#server)
* [`port`](#port)
* [`url_path`](#url_path)
* [`md5_url_path`](#md5_url_path)
* [`username`](#username)
* [`password`](#password)
* [`ensure`](#ensure)
* [`path`](#path)
* [`owner`](#owner)
* [`group`](#group)
* [`mode`](#mode)
* [`extract`](#extract)
* [`extract_path`](#extract_path)
* [`creates`](#creates)
* [`cleanup`](#cleanup)
* [`archive_path`](#archive_path)

##### <a name="server"></a>`server`

Data type: `String`



##### <a name="port"></a>`port`

Data type: `Integer`



##### <a name="url_path"></a>`url_path`

Data type: `String`



##### <a name="md5_url_path"></a>`md5_url_path`

Data type: `String`



##### <a name="username"></a>`username`

Data type: `String`



##### <a name="password"></a>`password`

Data type: `String`



##### <a name="ensure"></a>`ensure`

Data type: `Enum['present', 'absent']`



Default value: `present`

##### <a name="path"></a>`path`

Data type: `String`



Default value: `$name`

##### <a name="owner"></a>`owner`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="group"></a>`group`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="mode"></a>`mode`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="extract"></a>`extract`

Data type: `Optional[Boolean]`



Default value: ``undef``

##### <a name="extract_path"></a>`extract_path`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="creates"></a>`creates`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="cleanup"></a>`cleanup`

Data type: `Optional[Boolean]`



Default value: ``undef``

##### <a name="archive_path"></a>`archive_path`

Data type: `Optional[Stdlib::Compat::Absolute_path]`



Default value: ``undef``

### <a name="archivenexus"></a>`archive::nexus`

define: archive::nexus
======================

archive wrapper for downloading files from Nexus using REST API. Nexus API:
https://repository.sonatype.org/nexus-restlet1x-plugin/default/docs/path__artifact_maven_content.html

Parameters
----------

Examples
--------

archive::nexus { '/tmp/jtstand-ui-0.98.jar':
  url        => 'https://oss.sonatype.org',
  gav        => 'org.codehaus.jtstand:jtstand-ui:0.98',
  repository => 'codehaus-releases',
  packaging  => 'jar',
  extract    => false,
}

#### Parameters

The following parameters are available in the `archive::nexus` defined type:

* [`url`](#url)
* [`gav`](#gav)
* [`repository`](#repository)
* [`ensure`](#ensure)
* [`checksum_type`](#checksum_type)
* [`checksum_verify`](#checksum_verify)
* [`packaging`](#packaging)
* [`use_nexus3_urls`](#use_nexus3_urls)
* [`classifier`](#classifier)
* [`extension`](#extension)
* [`username`](#username)
* [`password`](#password)
* [`user`](#user)
* [`owner`](#owner)
* [`group`](#group)
* [`mode`](#mode)
* [`extract`](#extract)
* [`extract_path`](#extract_path)
* [`extract_flags`](#extract_flags)
* [`extract_command`](#extract_command)
* [`creates`](#creates)
* [`cleanup`](#cleanup)
* [`proxy_server`](#proxy_server)
* [`proxy_type`](#proxy_type)
* [`allow_insecure`](#allow_insecure)
* [`temp_dir`](#temp_dir)

##### <a name="url"></a>`url`

Data type: `String`



##### <a name="gav"></a>`gav`

Data type: `String`



##### <a name="repository"></a>`repository`

Data type: `String`



##### <a name="ensure"></a>`ensure`

Data type: `Enum['present', 'absent']`



Default value: `present`

##### <a name="checksum_type"></a>`checksum_type`

Data type: `Enum['none', 'md5', 'sha1', 'sha2','sha256', 'sha384', 'sha512']`



Default value: `'md5'`

##### <a name="checksum_verify"></a>`checksum_verify`

Data type: `Boolean`



Default value: ``true``

##### <a name="packaging"></a>`packaging`

Data type: `String`



Default value: `'jar'`

##### <a name="use_nexus3_urls"></a>`use_nexus3_urls`

Data type: `Boolean`



Default value: ``false``

##### <a name="classifier"></a>`classifier`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="extension"></a>`extension`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="username"></a>`username`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="password"></a>`password`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="user"></a>`user`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="owner"></a>`owner`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="group"></a>`group`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="mode"></a>`mode`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="extract"></a>`extract`

Data type: `Optional[Boolean]`



Default value: ``undef``

##### <a name="extract_path"></a>`extract_path`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="extract_flags"></a>`extract_flags`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="extract_command"></a>`extract_command`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="creates"></a>`creates`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="cleanup"></a>`cleanup`

Data type: `Optional[Boolean]`



Default value: ``undef``

##### <a name="proxy_server"></a>`proxy_server`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="proxy_type"></a>`proxy_type`

Data type: `Optional[String]`



Default value: ``undef``

##### <a name="allow_insecure"></a>`allow_insecure`

Data type: `Optional[Boolean]`



Default value: ``undef``

##### <a name="temp_dir"></a>`temp_dir`

Data type: `Optional[Stdlib::Absolutepath]`



Default value: ``undef``

## Resource types

### <a name="archive"></a>`archive`

Manage archive file download, extraction, and cleanup.

#### Properties

The following properties are available in the `archive` type.

##### `creates`

if file/directory exists, will not download/extract archive.

##### `ensure`

Valid values: `present`, `absent`

whether archive file should be present/absent (default: present)

Default value: `present`

#### Parameters

The following parameters are available in the `archive` type.

* [`allow_insecure`](#allow_insecure)
* [`checksum`](#checksum)
* [`checksum_type`](#checksum_type)
* [`checksum_url`](#checksum_url)
* [`checksum_verify`](#checksum_verify)
* [`cleanup`](#cleanup)
* [`cookie`](#cookie)
* [`digest_string`](#digest_string)
* [`digest_type`](#digest_type)
* [`digest_url`](#digest_url)
* [`download_options`](#download_options)
* [`extract`](#extract)
* [`extract_command`](#extract_command)
* [`extract_flags`](#extract_flags)
* [`extract_path`](#extract_path)
* [`filename`](#filename)
* [`group`](#group)
* [`headers`](#headers)
* [`password`](#password)
* [`path`](#path)
* [`provider`](#provider)
* [`proxy_server`](#proxy_server)
* [`proxy_type`](#proxy_type)
* [`source`](#source)
* [`target`](#target)
* [`temp_dir`](#temp_dir)
* [`url`](#url)
* [`user`](#user)
* [`username`](#username)

##### <a name="allow_insecure"></a>`allow_insecure`

Valid values: ``true``, ``false``, `yes`, `no`

ignore HTTPS certificate errors

Default value: ``false``

##### <a name="checksum"></a>`checksum`

Valid values: `%r{\b[0-9a-f]{5,128}\b}`, ``true``, ``false``, ``undef``, `nil`, `''`

archive file checksum (match checksum_type).

##### <a name="checksum_type"></a>`checksum_type`

Valid values: `none`, `md5`, `sha1`, `sha2`, `sha256`, `sha384`, `sha512`

archive file checksum type (none|md5|sha1|sha2|sha256|sha384|sha512).

Default value: `none`

##### <a name="checksum_url"></a>`checksum_url`

archive file checksum source (instead of specifying checksum)

##### <a name="checksum_verify"></a>`checksum_verify`

Valid values: ``true``, ``false``

whether checksum wil be verified (true|false).

Default value: ``true``

##### <a name="cleanup"></a>`cleanup`

Valid values: ``true``, ``false``

whether archive file will be removed after extraction (true|false).

Default value: ``true``

##### <a name="cookie"></a>`cookie`

archive file download cookie.

##### <a name="digest_string"></a>`digest_string`

Valid values: `%r{\b[0-9a-f]{5,128}\b}`

archive file checksum (match checksum_type)
(this parameter is for camptocamp/archive compatibility).

##### <a name="digest_type"></a>`digest_type`

Valid values: `none`, `md5`, `sha1`, `sha2`, `sha256`, `sha384`, `sha512`

archive file checksum type (none|md5|sha1|sha2|sha256|sha384|sha512)
(this parameter is camptocamp/archive compatibility).

##### <a name="digest_url"></a>`digest_url`

archive file checksum source (instead of specifying checksum)
(this parameter is for camptocamp/archive compatibility)

##### <a name="download_options"></a>`download_options`

provider download options (affects curl, wget, gs, and only s3 downloads for ruby provider)

##### <a name="extract"></a>`extract`

Valid values: ``true``, ``false``

whether archive will be extracted after download (true|false).

Default value: ``false``

##### <a name="extract_command"></a>`extract_command`

custom extraction command ('tar xvf example.tar.gz'), also support sprintf format ('tar xvf %s') which will be processed
with the filename: sprintf('tar xvf %s', filename)

##### <a name="extract_flags"></a>`extract_flags`

custom extraction options, this replaces the default flags. A string such as 'xvf' for a tar file would replace the
default xf flag. A hash is useful when custom flags are needed for different platforms. {'tar' => 'xzf', '7z' => 'x
-aot'}.

Default value: ``undef``

##### <a name="extract_path"></a>`extract_path`

target folder path to extract archive.

##### <a name="filename"></a>`filename`

archive file name (derived from path).

##### <a name="group"></a>`group`

extract command group (using this option will configure the archive file permisison to 0644 so the user can read the
file).

##### <a name="headers"></a>`headers`

optional header(s) to pass.

##### <a name="password"></a>`password`

password to download source file.

##### <a name="path"></a>`path`

namevar, archive file fully qualified file path.

##### <a name="provider"></a>`provider`

The specific backend to use for this `archive` resource. You will seldom need to specify this --- Puppet will usually
discover the appropriate provider for your platform.

##### <a name="proxy_server"></a>`proxy_server`

proxy address to use when accessing source

##### <a name="proxy_type"></a>`proxy_type`

Valid values: `none`, `ftp`, `http`, `https`

proxy type (none|ftp|http|https)

##### <a name="source"></a>`source`

archive file source, supports puppet|http|https|ftp|file|s3|gs uri.

##### <a name="target"></a>`target`

target folder path to extract archive. (this parameter is for camptocamp/archive compatibility)

##### <a name="temp_dir"></a>`temp_dir`

Specify an alternative temporary directory to use for copying files, if unset then the operating system default will be
used.

##### <a name="url"></a>`url`

archive file source, supports http|https|ftp|file uri.
(for camptocamp/archive compatibility)

##### <a name="user"></a>`user`

extract command user (using this option will configure the archive file permission to 0644 so the user can read the
file).

##### <a name="username"></a>`username`

username to download source file.

## Functions

### <a name="archiveartifactory_checksum"></a>`archive::artifactory_checksum`

Type: Ruby 4.x API

A function that returns the checksum value of an artifact stored in Artifactory

#### `archive::artifactory_checksum(Stdlib::HTTPUrl $url, Optional[Enum['sha1','sha256','md5']] $checksum_type)`

The archive::artifactory_checksum function.

Returns: `String` Returns the checksum.

##### `url`

Data type: `Stdlib::HTTPUrl`

The URL of the artifact.

##### `checksum_type`

Data type: `Optional[Enum['sha1','sha256','md5']]`

The checksum type.
Note the function will raise an error if you ask for sha256 but your artifactory instance doesn't have the sha256 value calculated.

### <a name="archiveartifactory_latest_url"></a>`archive::artifactory_latest_url`

Type: Ruby 4.x API

The archive::artifactory_latest_url function.

#### `archive::artifactory_latest_url(Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $url, Hash $maven_data)`

The archive::artifactory_latest_url function.

Returns: `Any`

##### `url`

Data type: `Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]`



##### `maven_data`

Data type: `Hash`



### <a name="archiveparse_artifactory_url"></a>`archive::parse_artifactory_url`

Type: Ruby 4.x API

A function to parse an Artifactory maven 2 repository URL

#### `archive::parse_artifactory_url(Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $url)`

A function to parse an Artifactory maven 2 repository URL

Returns: `Any`

##### `url`

Data type: `Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]`



