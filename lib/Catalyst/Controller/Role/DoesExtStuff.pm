package Catalyst::Controller::Role::DoesExtStuff;

use Moose::Role;
requires 'pages';

sub extjs_parcel {
   my ($self, $paginated_rs, $method) = @_;
   $refthing ||= 'TO_JSON';
   my $pager = $paginated_rs->pager;
   my $total = $pager->total_entries;

   # this is a workaround for MSSQL
   my $rows = $pager->entries_per_page || $self->pages;
   my $page = $pager->current_page;
   my $is_last_page = $pager->last_page == $page;
   my $skip = $rows - $total % $rows + 1;

   # this json stuff needs to be in a completely separate class
   my $data = { data => [], total => $total };

   TO_JSON:
   while ( my $row = $paginated_rs->next() ) {
      $skip--;
      next TO_JSON if $page != 1 and $is_last_page and $skip > 0; # workaround
      push @{ $data->{data} }, $row->$refthing; # json stuff
   }

   return $data;
}

1;
