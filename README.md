# Rollbar-SF-APEX

This library detects errors and exceptions in your application and reports them to [Rollbar](https://rollbar.com) for alerts, reporting, and analysis for your SalesForce APEX code.

# Setup Instructions

1. Allow connections to `https://api.rollbar.com/api/1/item/` in `Remote Sites` under `Setup` in your org.
2. Install `rollbar-sf-apex` as an app in your org.

# Usage and Reference

```apex
Rollbar.init([access_token], [environment]);
Rollbar.log([level], [message]);
```

# License
Rollbar-SF-APEX is free software released under the MIT License. See [LICENSE.txt](LICENSE.txt) for details.
