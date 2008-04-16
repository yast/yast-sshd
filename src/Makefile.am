# Makefile.am for sshd/src

yncludedir = @yncludedir@/sshd

client_DATA =			\
	sshd.ycp		\
	sshd_auto.ycp

ynclude_DATA =			\
	helps.ycp		\
	wizards.ycp		\
	dialogs.ycp		\
	complex.ycp

desktop_DATA =			\
	sshd.desktop

module_DATA =			\
	Sshd.ycp		\
	SshdCommandLine.ycp

rncdir =  $(schemadir)/autoyast/rnc
rnc_DATA = sshd_config.rnc

# create a symlink for local build, #145327
sshd:
	ln -sf . $@
ycpchook = sshd

EXTRA_DIST = $(client_DATA) $(ynclude_DATA) $(module_DATA) $(desktop_DATA) $(rnc_DATA)

include $(top_srcdir)/Makefile.am.common
