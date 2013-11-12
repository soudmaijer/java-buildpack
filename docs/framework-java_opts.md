# `JAVA_OPTS` Framework
The `JAVA_OPTS` Framework contributes arbitrary Java options to the application at runtime.

<table>
  <tr>
    <td><strong>Detection Criterion</strong></td><td><tt>java_opts</tt> set</td>
  </tr>
  <tr>
    <td><strong>Tags</strong></td><td><tt>java_opts</tt></td>
  </tr>
</table>
Tags are printed to standard output by the buildpack detect script


## Configuration
For general information on configuring the buildpack, refer to [Configuration and Extension][].

The framework can be configured by modifying the [`config/javaopts.yml`][] file.

| Name | Description
| ---- | -----------
| `java_opts` | The Java options to use when running the application.  All values are used without modification when invoking the JVM. The options are specified as a single YAML scalar in plain style or enclosed in single or double quotes.

[Configuration and Extension]: ../README.md#Configuration-and-Extension
[`config/javaopts.yml`]: ../config/javaopts.yml
