package OpenOffice::UNO;
require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

@EXPORT = qw( createComponentContext );

bootstrap OpenOffice::UNO;

1;
