#!/usr/bin/perl

use strict; # Good practice
use warnings; # Good practice
use Data::Dumper; # Perl core module

# get md file
my $giturl = "https://github.com/itech001/ciandcd.git";
my $ret = 0;
$ret = system("rm -rf ciandcd");
$ret = system("git clone $giturl");
if($ret){
  print "Error:failed for git clone\n";
  exit 1;
}

# read md file
my $mdfile = "ciandcd/README.md";
my $res = [];
my $section = {};
my $items = [];
open FILE, $mdfile or die "Error: failed to open md file\n";
while (my $line = <FILE>){
  chomp $line;
  next if($line =~ /^\s*$/);

  if($line =~ /^##(.*)$/){
    $section = {};
    $section->{name} = $1;
    push @$res, $section; 
    $items = [];
    $section->{items} = $items;
  }elsif($line =~ /^([^#\*].*)$/){
    $section->{desc} .= $1;
  }elsif($line =~ /^\*\s*\[(.*)\]\((.*)\)\s*(.*)$/){
    my $item = {};
    $item->{name} = $1;
    $item->{url} = $2;
    $item->{detail} = $3;
    push(@$items, $item);
  }else{
  } 
} 

#print Dumper($res);

# left html
my $left = <<EOU;
      <div class="col-md-3" id="leftCol">
        <ul class="nav nav-stacked" id="sidebar">
EOU
for my $s (@$res){
  my $n = $s->{name};
  my $id = $n; $id = lc($id); $id =~ s/ /-/g;
  $s->{id} = $id;
  $left .= "<li><a href='#$id'>$n</a></li>";
}
$left .= "</div>";

# right html
my $right = "<div class='col-md-9'>";
for my $s (@$res){
  my $name = $s->{name};
  my $id = $s->{id};
  my $des = $s->{desc};
  $right .= "<h2 id='$id'>$name</h2><ul>";
  $right .= "<code>$des</code>";
  my $items = $s->{items};
  for my $i (@$items){
    my $n = $i->{name};
    my $u = $i->{url};
    my $d = $i->{detail};
    $right .= "<li><a href=$u>$n</a>&nbsp&nbsp$d</li>";
  }
  $right .= "</ul>";
}
$right .= "</div>";

# whole html
my $html = $left . $right;

my $index = `cat index.html.template`;
$index =~ s/CIANDCD_BODY/$html/;
open INDEX, "> index.html" or die "Can not write index.html: $!\n";
print INDEX $index;
close INDEX;

 
