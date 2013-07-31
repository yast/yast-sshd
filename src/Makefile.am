# Sources for sshd

module_DATA = \
  modules/SshdCommandLine.rb \
  modules/Sshd.rb

client_DATA = \
  clients/sshd_auto.rb \
  clients/sshd.rb

yncludedir = @yncludedir@/sshd
ynclude_DATA = \
  include/sshd/wizards.rb \
  include/sshd/dialogs.rb \
  include/sshd/complex.rb \
  include/sshd/helps.rb

schemafilesdir = $(schemadir)/autoyast/rnc
schemafiles_DATA = \
  autoyast-rnc/sshd_config.rnc

desktop_DATA = \
  desktop/sshd.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(schemafiles_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common