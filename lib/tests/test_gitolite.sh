#!@bats@/bin/bats --tap

#
# Prepare git settings
#
@test "Prepare git settings" {
	cd /root
	mkdir -m 0700 /root/.ssh
	cp @out@/data/*_key /root/.ssh/
	cp @out@/data/*_key.pub /root/.ssh/
	chmod 0600 /root/.ssh/*_key

	echo "Host gitolite-admin
	HostName gitolite
	StrictHostKeyChecking = no
	IdentityFile = ~/.ssh/admin_key

	Host gitolite
	StrictHostKeyChecking = no
	IdentityFile = ~/.ssh/test_key" > /root/.ssh/config

	git config --global push.default simple
}

#
# configure repositories
#
@test "configure repositories as admin" {
	cd /root
	run git clone gitolite@gitolite-admin:gitolite-admin
	[ $status -eq 0 ]
	cd gitolite-admin
	git config user.name "Admin"
	git config user.email "admin@example.com"

	# add user and repositories
	echo "
	repo private_repo
	    RW+ = user

	repo public_repo
	    RW+ = user
	    R   = gitweb
	" >> conf/gitolite.conf
	cp @out@/data/test_key.pub keydir/user.pub

	run git add conf/gitolite.conf keydir/user.pub
	[ $status -eq 0 ]
	run git commit -m "add user and repos"
	[ $status -eq 0 ]
	run git push
	[ $status -eq 0 ]
}

#
# access user repo
#
@test "fill public repo as user" {
	cd /root
	run git clone gitolite@gitolite:public_repo
	[ $status -eq 0 ]
	cd public_repo
	git config user.name "User"
	git config user.email "user@example.com"

	echo "Hello public world" > readme.md
	git add readme.md
	git commit -m "start public_repo with a readme"
	run git push
	[ $status -eq 0 ]
}
@test "fill private repo as user" {
	cd /root
	run git clone gitolite@gitolite:private_repo
	[ $status -eq 0 ]
	cd private_repo
	git config user.name "User"
	git config user.email "user@example.com"

	echo "Hello private world" > readme.md
	git add readme.md
	git commit -m "start private_repo with a readme"
	run git push
	[ $status -eq 0 ]
}

#
# can not access admin-repo as user
#
@test "can not access admin-repo as user" {
	run git clone gitolite@gitolite:gitolite-admin gitolite-admin-user
	[ $status -ne 0 ]
	[[ "$output" =~ "DENIED" ]]
}
