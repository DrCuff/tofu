# Experiments with tofu

Here's tofu in a podman from scratch with alpine (we didn't end up using this, but wanted to see how it went, may come back to this later)
![tofu](./tofu.gif)

# Notes and Experiments

Here we are going to use two machines, an OSX laptop (midnight) and a linux server running Fedora 43 (linuxmini), the reason for this is linuxmini is going to take the place of a cloud provider to be able to start and stop and fiddle with remote machine images.  The howto for tofu and incus is here, we are using v1.0.2

https://search.opentofu.org/provider/lxc/incus/latest


So, let's allow an OSX to talk to a linux container system to start and stop OpenTofu images the easy way:

Fedora needs a tweak for idmaps, this seems specific to fedora:
```
sudo dnf install uidmap shadow-utils
sudo echo "root:1000000:1000000000" | sudo tee -a /etc/subuid /etc/subgid
```

Also, double check you can start an instance locally on `linuxmini` first:
```
jcuff@linuxmini:~$ incus launch images:ubuntu/22.04 test
Launching test
jcuff@linuxmini:~$ incus list
+------+---------+------+------------------------------------------------+-----------+-----------+
| NAME |  STATE  | IPV4 |                      IPV6                      |   TYPE    | SNAPSHOTS |
+------+---------+------+------------------------------------------------+-----------+-----------+
| test | RUNNING |      | fd42:a0ab:c92f:dc89:1266:6aff:fe51:c986 (eth0) | CONTAINER | 0         |
+------+---------+------+------------------------------------------------+-----------+-----------+
```


First set up incus trust mechanisms:
```
jcuff@midnight tofu % incus remote add linuxmini
Generating a client certificate. This may take a minute...
Certificate fingerprint: e3a30.....
ok (y/n/[fingerprint])? y
```

Now log in to the remote incus server at `linuxmini` and run:
```
jcuff@linuxmini:~$ incus config trust add midnight
```

Back on the client `midnight` run this and cut and paste the token (giant ass string) that we generated from `incus config trust add midnight` above.
```
Trust token for linuxmini: eyJjbGllbnRf....
Client certificate now trusted by server: linuxmini
```

Then you can switch remotes:
```
jcuff@midnight ~ % incus list
This client hasn't been configured to use a remote server yet.
As your platform can't run native Linux instances, you must connect to a remote server.
If you already added a remote server, make it the default with "incus remote switch NAME".

jcuff@midnight ~ % incus remote switch linuxmini 
jcuff@midnight ~ % incus list                   
+------+-------+------+------+------+-----------+
| NAME | STATE | IPV4 | IPV6 | TYPE | SNAPSHOTS |
+------+-------+------+------+------+-----------+
jcuff@midnight ~ % 
```

Use homebrew to quickly install on OSX `midnight`:
```
jcuff@midnight tofu % brew update
jcuff@midnight tofu % brew install opentofu
==> Fetching downloads for: opentofu
✔︎ Bottle Manifest opentofu (1.11.2)                                                                                                  Downloaded    7.4KB/  7.4KB
✔︎ Bottle opentofu (1.11.2)                                                                                                           Downloaded   30.5MB/ 30.5MB
==> Pouring opentofu--1.11.2.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/opentofu/1.11.2: 7 files, 105.7MB

```

Then switch into the cluster directory, init tofu:
```
jcuff@midnight tofu.github % cd cluster 
jcuff@midnight cluster % vi main.tf
jcuff@midnight cluster % tofu init

Initializing the backend...

Initializing provider plugins...
- Finding lxc/incus versions matching "1.0.2"...
- Installing lxc/incus v1.0.2...
- Installed lxc/incus v1.0.2 (signed, key ID C638974D64792D67)

OpenTofu has been successfully initialized!
```

You can now plan and apply an install method from `main.tf`:
```
jcuff@midnight cluster % tofu apply

OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

(snip)

incus_instance.headnode: Creating...
incus_instance.headnode: Creation complete after 3s [name=headnode]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```

and finally confirm remote is running with tofu provisioned start by using regular incus commands:
```
jcuff@midnight cluster % incus list
+----------+---------+------+------------------------------------------------+-----------+-----------+
|   NAME   |  STATE  | IPV4 |                      IPV6                      |   TYPE    | SNAPSHOTS |
+----------+---------+------+------------------------------------------------+-----------+-----------+
| headnode | RUNNING |      | fd42:a0ab:c92f:dc89:1266:6aff:fe76:70d6 (eth0) | CONTAINER | 0         |
+----------+---------+------+------------------------------------------------+-----------+-----------+
jcuff@midnight cluster % 
```

Right - what next?  ;-)
