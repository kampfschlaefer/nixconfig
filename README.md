# What is this?

This is the [Nixos](http://nixos.org) configuration of my machine(s).

# Why?

So that others my learn either from my genius or my mistakes. The later gives much more opportunity to learn😏.

Take a look, use it for inspiration, ask me questions about it via 'issues'.

# Isn't that insecure?

Hopefully I do not leak sensistive configuration in here without encrypting it. Don't worry, the initial hashed password in here is really just an initial password and gets changed as soon as a new machine is installed. Other secrets should be GPG encrypted…

# Why can I not see the nixpkgs resource?

I do use the nixpkgs tree as submodule. That way I can always reference an exact version of the whole system.

*But* it links to my own branch in my private repo where I have custom patches on top of nix. So nothing to see here…