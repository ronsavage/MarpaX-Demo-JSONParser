use MarpaX::Demo::JSONParser;

use Path::Tiny; # For path().

use Test::More;
use Test::Exception;

use Try::Tiny;

# ------------------------------------------------

sub run_test
{
	my($bnf_file, $string) = @_;

	my($result);

	# Use try to catch die.

	try
	{
		$result = MarpaX::Demo::JSONParser -> new(bnf_file => $bnf_file) -> parse($string);
	};

	return $result;

} # End of run_test.

# ------------------------------------------------

sub run_tests
{
	my($bnf_file) = @_;
	$bnf_file     = "$bnf_file"; # See Path::Tiny :-(.

	$data = run_test($bnf_file, '{[}');
	is($data, undef, "$bnf_file. Expect parse to die");

	$data = run_test($bnf_file, '{"["}');
	is($data, undef, "$bnf_file. Expect parse to die");

	$data = run_test($bnf_file, '{[[}');
	is($data, undef, "$bnf_file. Expect parse to die");

	$data = run_test($bnf_file, '{"[["}');
	is($data, undef, "$bnf_file. Expect parse to die");

	$data = run_test($bnf_file, '{');
	is($data, undef, "$bnf_file. Expect parse to die");

	$data = run_test($bnf_file, '"a');
	is($data, undef, "$bnf_file. Expect parse to die");

	my $data = run_test($bnf_file, '{"test":"1"}');
	is($$data{test}, 1, "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, '{"test":[1,2,3]}');
	is_deeply($$data{test}, [1,2,3], "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, '{"test":true}');
	is($$data{test}, 1, "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, '{"test":false}');
	is($$data{test}, '', "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, '{"test":null}');
	is($$data{test}, undef, "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, '{"test":null, "test2":"hello world"}');
	is($$data{test}, undef, "$bnf_file. Expect parse to succeed");
	is($data->{test2}, "hello world", "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, '{"test":"1.25"}');
	is($$data{test}, '1.25', "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, '{"test":"1.25e4"}');
	is($$data{test}, '1.25e4', "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, '[]');
	is_deeply($data, [], "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, <<'JSON');
	[
	      {
	         "precision": "zip",
	         "Latitude":  37.7668,
	         "Longitude": -122.3959,
	         "Address":   "",
	         "City":      "SAN FRANCISCO",
	         "State":     "CA",
	         "Zip":       "94107",
	         "Country":   "US"
	      },
	      {
	         "precision": "zip",
	         "Latitude":  37.371991,
	         "Longitude": -122.026020,
	         "Address":   "",
	         "City":      "SUNNYVALE",
	         "State":     "CA",
	         "Zip":       "94085",
	         "Country":   "US"
	      }
	]
JSON

	is_deeply($data, [
	    { "precision"=>"zip", Latitude => "37.7668", Longitude=>"-122.3959",
	      "Country" => "US", Zip => 94107, Address => '',
	      City => "SAN FRANCISCO", State => 'CA' },
	    { "precision" => "zip", Longitude => "-122.026020", Address => "",
	      City => "SUNNYVALE", Country => "US", Latitude => "37.371991",
	      Zip => 94085, State => "CA" }
	], "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, <<'JSON');
	{
	    "Image": {
	        "Width":  800,
	        "Height": 600,
	        "Title":  "View from 15th Floor",
	        "Thumbnail": {
	            "Url":    "http://www.example.com/image/481989943",
	            "Height": 125,
	            "Width":  "100"
	        },
	        "IDs": [116, 943, 234, 38793]
	    }
	}
JSON

	is_deeply($data, {
	    "Image" => {
	        "Width" => 800, "Height" => 600,
	        "Title" => "View from 15th Floor",
	        "Thumbnail" => {
	            "Url" => "http://www.example.com/image/481989943",
	            "Height" => 125,
	            "Width" => 100,
	        },
	        "IDs" => [ 116, 943, 234, 38793 ],
	    }
	}, "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, <<'JSON');
	{
	    "source" : "<a href=\"http://janetter.net/\" rel=\"nofollow\">Janetter</a>",
	    "entities" : {
	        "user_mentions" : [ {
	                "name" : "James Governor",
	                "screen_name" : "moankchips",
	                "indices" : [ 0, 10 ],
	                "id_str" : "61233",
	                "id" : 61233
	            } ],
	        "media" : [ ],
	        "hashtags" : [ ],
	        "urls" : [ ]
	    },
	    "in_reply_to_status_id_str" : "281400879465238529",
	    "geo" : {
	    },
	    "id_str" : "281405942321532929",
	    "in_reply_to_user_id" : 61233,
	    "text" : "@monkchips Ouch. Some regrets are harsher than others.",
	    "id" : "281405942321532929",
	    "in_reply_to_status_id" : "281400879465238529",
	    "created_at" : "Wed Dec 19 14:29:39 +0000 2012",
	    "in_reply_to_screen_name" : "monkchips",
	    "in_reply_to_user_id_str" : "61233",
	    "user" : {
	        "name" : "Sarah Bourne",
	        "screen_name" : "sarahebourne",
	        "protected" : false,
	        "id_str" : "16010789",
	        "profile_image_url_https" : "https://si0.twimg.com/profile_images/638441870/Snapshot-of-sb_normal.jpg",
	        "id" : 16010789,
	        "verified" : false
	    }
	}
JSON

	is_deeply($data, {
	    "source" => "<a href=\"http://janetter.net/\" rel=\"nofollow\">Janetter</a>",
	    "entities" => {
	        "user_mentions" => [ {
	                "name" => "James Governor",
	                "screen_name" => "moankchips",
	                "indices" => [ 0, 10 ],
	                "id_str" => "61233",
	                "id" => 61233
	            } ],
	        "media" => [ ],
	        "hashtags" => [ ],
	        "urls" => [ ]
	    },
	    "in_reply_to_status_id_str" => "281400879465238529",
	    "geo" => {
	    },
	    "id_str" => "281405942321532929",
	    "in_reply_to_user_id" => 61233,
	    "text" => "\@monkchips Ouch. Some regrets are harsher than others.",
	    "id" => "281405942321532929",
	    "in_reply_to_status_id" => "281400879465238529",
	    "created_at" => "Wed Dec 19 14:29:39 +0000 2012",
	    "in_reply_to_screen_name" => "monkchips",
	    "in_reply_to_user_id_str" => "61233",
	    "user" => {
	        "name" => "Sarah Bourne",
	        "screen_name" => "sarahebourne",
	        "protected" => '', # false.
	        "id_str" => "16010789",
	        "profile_image_url_https" => "https://si0.twimg.com/profile_images/638441870/Snapshot-of-sb_normal.jpg",
	        "id" => 16010789,
	        "verified" => '' # false.
	    }
	}, "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, <<'JSON');
	{ "test":  "\u2603" }
JSON

	is($$data{test}, "\x{2603}", "$bnf_file. Expect parse to succeed");

	$data = run_test($bnf_file, <<'JSON');
	{ "test":  "éáóüöï" }
JSON

	is($$data{test}, "éáóüöï", "$bnf_file. Expect parse to succeed");

} # End of run_tests;

# ------------------------------------------------

for (qw/json.1.bnf json.2.bnf/)
{
	run_tests(path('share', $_) );
}

done_testing();
