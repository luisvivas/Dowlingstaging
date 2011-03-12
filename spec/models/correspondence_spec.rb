# t.string :to_name
# t.string :to_email
# t.string :contact_id
# t.string :user_id
# t.boolean :outgoing
# t.string :from_name
# t.string :from_email
# t.string :subject
# t.text :body
# t.integer :attachments
require 'spec_helper'

describe Correspondence do
  describe "SendGrid conversion" do
    before(:all) do
      @supplier = Factory.create(:contact, :first_name => "John", :last_name => "Supplier", :email => "john123@supplier.com")
      @customer = Factory.create(:contact, :first_name => "Jim", :last_name => "Customer", :email => "jim@queensu.ca")
      @kevin = Factory.create(:user, :first_name => "Kevin", :last_name => "Dowling", :email => "kevin@dowling.com")
      @david = Factory.create(:user, :first_name => "David", :last_name => "Dowling", :email => "david@dowling.com")
      @rfq = Factory.create(:request_for_quote)
      @quote = Factory.create(:quote)
    end
    
    describe "incoming emails" do  
      it "should parse an unknown sender and known receiver" do
        @params = {"headers"=>"Received: by 127.0.0.1 with SMTP id rRDnTCiqCA\n        Mon, 05 Jul 2010 18:26:35 -0700 (PDT)\nReceived: from mail-iw0-f177.google.com (unknown [10.9.180.37])\n\tby mx1.sendgrid.net (Postfix) with ESMTP id 28CC646548E\n\tfor <kevin@watch.dowling.com>; Mon,  5 Jul 2010 18:26:35 -0700 (PDT)\nReceived: by iwn40 with SMTP id 40so3158802iwn.8\n        for <kevin@watch.dowling.com>; Mon, 05 Jul 2010 18:26:34 -0700 (PDT)\nDKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;\n        d=gmail.com; s=gamma;\n        h=domainkey-signature:mime-version:received:received:date:message-id\n         :subject:from:to:content-type;\n        bh=utacxs7soi5rIybgFceFG5fP6tv2Jf4KboxiuW8Z1xE=;\n        b=agtTPTy9u7dJp4lUKOpTGL+Ji28SUGUQoQi5K7N4xOcTNHpYBvTsKQPG2LaYQLu+9R\n         g/B7rrzT3agEmqtk+0P27i2MuB7rbdDJ8WsMrLsgXLwV5klfrAmdEodfPjaw4QgioXiN\n         msYEkTde8+pVkbZdKQkXmPkTK7fRdWYScF63A=\nDomainKey-Signature: a=rsa-sha1; c=nofws;\n        d=gmail.com; s=gamma;\n        h=mime-version:date:message-id:subject:from:to:content-type;\n        b=E4WN6pprh5tsFey2JIovmLeCHKd3WddHPfhEcfE1UNSl9JzIVR5epAXnhXg/vPYn/v\n         q5F6b8O0OaJS8udeZGiZOTu8FH+w/FfpLMpvWrCTDrVHmb3qvbY4AXiL2wUc+L4hirvT\n         KY1uhSWurliMud5nrpA1m0rbYX/W6INgTyro4=\nMIME-Version: 1.0\nReceived: by 10.231.85.144 with SMTP id o16mr4237565ibl.182.1278379594815; \n\tMon, 05 Jul 2010 18:26:34 -0700 (PDT)\nReceived: by 10.231.130.102 with HTTP; Mon, 5 Jul 2010 18:26:34 -0700 (PDT)\nDate: Mon, 5 Jul 2010 21:26:34 -0400\nMessage-ID: <AANLkTilkHyFooIOT7c2Sf3U2kBzWX3g7rqRrckNT3skh@mail.gmail.com>\nSubject: Test Email from harry\nFrom: Harry Brundage <harry.brundage@gmail.com>\nTo: Kevin Dowling <kevin@watch.dowling.com>\nContent-Type: multipart/alternative; boundary=001485ec0de8a318f9048aadf1bb\n", "attachments"=>"0", "subject"=>"Test from harry brundage\n", "to"=>"Kevin Dowling <kevin@watch.dowling.com>\n", "html"=>"test<br clear=\"all\"><br>-- <br>Cheers,<br>Harry Brundage<br>\n", "from"=>"Harry Brundage <harry.brundage@gmail.com>\n", "text"=>"test\r\n\r\n-- \r\nCheers,\r\nHarry Brundage\n"}
        @model = parse_sendgrid(@params)
        @model.incoming.should == true
        
        @model.to_name.should == "Kevin Dowling"
        @model.to_email.should == "kevin@dowling.com"
        @model.user.should == @kevin
        
        @model.from_name.should == "Harry Brundage"
        @model.from_email.should == "harry.brundage@gmail.com"
        @model.contact.should be_nil
        
        @model.subject.should == "Test Email from harry"
        @model.body.should == "test\n\n-- \nCheers,\nHarry Brundage\n"
        @model.attachments.should == 0
        @model.should be_valid
      end
      
      it "should parse a known sender and receiver" do
        @params = {"headers"=>"Received: by 127.0.0.1 with SMTP id rRDnTCiqCA\n        Mon, 05 Jul 2010 18:26:35 -0700 (PDT)\nReceived: from mail-iw0-f177.google.com (unknown [10.9.180.37])\n\tby mx1.sendgrid.net (Postfix) with ESMTP id 28CC646548E\n\tfor <kevin@watch.dowling.com>; Mon,  5 Jul 2010 18:26:35 -0700 (PDT)\nReceived: by iwn40 with SMTP id 40so3158802iwn.8\n        for <kevin@watch.dowling.com>; Mon, 05 Jul 2010 18:26:34 -0700 (PDT)\nDKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;\n        d=gmail.com; s=gamma;\n        h=domainkey-signature:mime-version:received:received:date:message-id\n         :subject:from:to:content-type;\n        bh=utacxs7soi5rIybgFceFG5fP6tv2Jf4KboxiuW8Z1xE=;\n        b=agtTPTy9u7dJp4lUKOpTGL+Ji28SUGUQoQi5K7N4xOcTNHpYBvTsKQPG2LaYQLu+9R\n         g/B7rrzT3agEmqtk+0P27i2MuB7rbdDJ8WsMrLsgXLwV5klfrAmdEodfPjaw4QgioXiN\n         msYEkTde8+pVkbZdKQkXmPkTK7fRdWYScF63A=\nDomainKey-Signature: a=rsa-sha1; c=nofws;\n        d=gmail.com; s=gamma;\n        h=mime-version:date:message-id:subject:from:to:content-type;\n        b=E4WN6pprh5tsFey2JIovmLeCHKd3WddHPfhEcfE1UNSl9JzIVR5epAXnhXg/vPYn/v\n         q5F6b8O0OaJS8udeZGiZOTu8FH+w/FfpLMpvWrCTDrVHmb3qvbY4AXiL2wUc+L4hirvT\n         KY1uhSWurliMud5nrpA1m0rbYX/W6INgTyro4=\nMIME-Version: 1.0\nReceived: by 10.231.85.144 with SMTP id o16mr4237565ibl.182.1278379594815; \n\tMon, 05 Jul 2010 18:26:34 -0700 (PDT)\nReceived: by 10.231.130.102 with HTTP; Mon, 5 Jul 2010 18:26:34 -0700 (PDT)\nDate: Mon, 5 Jul 2010 21:26:34 -0400\nMessage-ID: <AANLkTilkHyFooIOT7c2Sf3U2kBzWX3g7rqRrckNT3skh@mail.gmail.com>\nSubject: Test Email from harry\nFrom: John Supplier <john123@supplier.com>\nTo: Kevin Dowling <kevin@watch.dowling.com>\nContent-Type: multipart/alternative; boundary=001485ec0de8a318f9048aadf1bb\n", "attachments"=>"0", "subject"=>"Test from harry brundage\n", "to"=>"Kevin Dowling <kevin@watch.dowling.com>\n", "html"=>"test<br clear=\"all\"><br>-- <br>Cheers,<br>Harry Brundage<br>\n", "from"=>"John Supplier <john123@supplier.com>\n", "text"=>"test\r\n\r\n-- \r\nCheers,\r\nHarry Brundage\n"}
        @model = parse_sendgrid(@params)
        @model.incoming.should == true
        
        @model.to_name.should == "Kevin Dowling"
        @model.to_email.should == "kevin@dowling.com"
        @model.user.should == @kevin
        
        @model.from_name.should == "John Supplier"
        @model.from_email.should == "john123@supplier.com"
        @model.contact.should == @supplier
        
        @model.subject.should == "Test Email from harry"
        @model.body.should == "test\n\n-- \nCheers,\nHarry Brundage\n"
        @model.attachments.should == 0
        @model.should be_valid
      end
      
      it "should find a referenced RFQ" do
        @params = {"headers"=>"Received: by 127.0.0.1 with SMTP id rRDnTCiqCA\n        Mon, 05 Jul 2010 18:26:35 -0700 (PDT)\nReceived: from mail-iw0-f177.google.com (unknown [10.9.180.37])\n\tby mx1.sendgrid.net (Postfix) with ESMTP id 28CC646548E\n\tfor <kevin@watch.dowling.com>; Mon,  5 Jul 2010 18:26:35 -0700 (PDT)\nReceived: by iwn40 with SMTP id 40so3158802iwn.8\n        for <kevin@watch.dowling.com>; Mon, 05 Jul 2010 18:26:34 -0700 (PDT)\nDKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;\n        d=gmail.com; s=gamma;\n        h=domainkey-signature:mime-version:received:received:date:message-id\n         :subject:from:to:content-type;\n        bh=utacxs7soi5rIybgFceFG5fP6tv2Jf4KboxiuW8Z1xE=;\n        b=agtTPTy9u7dJp4lUKOpTGL+Ji28SUGUQoQi5K7N4xOcTNHpYBvTsKQPG2LaYQLu+9R\n         g/B7rrzT3agEmqtk+0P27i2MuB7rbdDJ8WsMrLsgXLwV5klfrAmdEodfPjaw4QgioXiN\n         msYEkTde8+pVkbZdKQkXmPkTK7fRdWYScF63A=\nDomainKey-Signature: a=rsa-sha1; c=nofws;\n        d=gmail.com; s=gamma;\n        h=mime-version:date:message-id:subject:from:to:content-type;\n        b=E4WN6pprh5tsFey2JIovmLeCHKd3WddHPfhEcfE1UNSl9JzIVR5epAXnhXg/vPYn/v\n         q5F6b8O0OaJS8udeZGiZOTu8FH+w/FfpLMpvWrCTDrVHmb3qvbY4AXiL2wUc+L4hirvT\n         KY1uhSWurliMud5nrpA1m0rbYX/W6INgTyro4=\nMIME-Version: 1.0\nReceived: by 10.231.85.144 with SMTP id o16mr4237565ibl.182.1278379594815; \n\tMon, 05 Jul 2010 18:26:34 -0700 (PDT)\nReceived: by 10.231.130.102 with HTTP; Mon, 5 Jul 2010 18:26:34 -0700 (PDT)\nDate: Mon, 5 Jul 2010 21:26:34 -0400\nMessage-ID: <AANLkTilkHyFooIOT7c2Sf3U2kBzWX3g7rqRrckNT3skh@mail.gmail.com>\nSubject: Test Email from harry\nFrom: John Supplier <john123@supplier.com>\nTo: Kevin Dowling <kevin@watch.dowling.com>\nContent-Type: multipart/alternative; boundary=001485ec0de8a318f9048aadf1bb\n", "attachments"=>"0", "subject"=>"Test from harry brundage\n", "to"=>"Kevin Dowling <kevin@watch.dowling.com>\n", "html"=>"test talking about [!!"+@rfq.discussion_tag+"]<br clear=\"all\"><br>-- <br>Cheers,<br>Harry Brundage<br>\n", "from"=>"John Supplier <john123@supplier.com>\n", "text"=>"test talking about [!!"+@rfq.discussion_tag+"]\r\n\r\n-- \r\nCheers,\r\nHarry Brundage\n"}
        @model = parse_sendgrid(@params, true)
        @model.discussable.should == @rfq
      end
      
      it "should find a referenced quote without the the pound symbol in the tag" do
        @params = {"headers"=>"Received: by 127.0.0.1 with SMTP id rRDnTCiqCA\n        Mon, 05 Jul 2010 18:26:35 -0700 (PDT)\nReceived: from mail-iw0-f177.google.com (unknown [10.9.180.37])\n\tby mx1.sendgrid.net (Postfix) with ESMTP id 28CC646548E\n\tfor <kevin@watch.dowling.com>; Mon,  5 Jul 2010 18:26:35 -0700 (PDT)\nReceived: by iwn40 with SMTP id 40so3158802iwn.8\n        for <kevin@watch.dowling.com>; Mon, 05 Jul 2010 18:26:34 -0700 (PDT)\nDKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;\n        d=gmail.com; s=gamma;\n        h=domainkey-signature:mime-version:received:received:date:message-id\n         :subject:from:to:content-type;\n        bh=utacxs7soi5rIybgFceFG5fP6tv2Jf4KboxiuW8Z1xE=;\n        b=agtTPTy9u7dJp4lUKOpTGL+Ji28SUGUQoQi5K7N4xOcTNHpYBvTsKQPG2LaYQLu+9R\n         g/B7rrzT3agEmqtk+0P27i2MuB7rbdDJ8WsMrLsgXLwV5klfrAmdEodfPjaw4QgioXiN\n         msYEkTde8+pVkbZdKQkXmPkTK7fRdWYScF63A=\nDomainKey-Signature: a=rsa-sha1; c=nofws;\n        d=gmail.com; s=gamma;\n        h=mime-version:date:message-id:subject:from:to:content-type;\n        b=E4WN6pprh5tsFey2JIovmLeCHKd3WddHPfhEcfE1UNSl9JzIVR5epAXnhXg/vPYn/v\n         q5F6b8O0OaJS8udeZGiZOTu8FH+w/FfpLMpvWrCTDrVHmb3qvbY4AXiL2wUc+L4hirvT\n         KY1uhSWurliMud5nrpA1m0rbYX/W6INgTyro4=\nMIME-Version: 1.0\nReceived: by 10.231.85.144 with SMTP id o16mr4237565ibl.182.1278379594815; \n\tMon, 05 Jul 2010 18:26:34 -0700 (PDT)\nReceived: by 10.231.130.102 with HTTP; Mon, 5 Jul 2010 18:26:34 -0700 (PDT)\nDate: Mon, 5 Jul 2010 21:26:34 -0400\nMessage-ID: <AANLkTilkHyFooIOT7c2Sf3U2kBzWX3g7rqRrckNT3skh@mail.gmail.com>\nSubject: Test Email from harry\nFrom: John Supplier <john123@supplier.com>\nTo: Kevin Dowling <kevin@watch.dowling.com>\nContent-Type: multipart/alternative; boundary=001485ec0de8a318f9048aadf1bb\n", "attachments"=>"0", "subject"=>"Test from harry brundage\n", "to"=>"Kevin Dowling <kevin@watch.dowling.com>\n", "html"=>"test talking about [!!Q"+@quote.id.to_s+"]<br clear=\"all\"><br>-- <br>Cheers,<br>Harry Brundage<br>\n", "from"=>"John Supplier <john123@supplier.com>\n", "text"=>"test talking about [!!Q"+@quote.id.to_s+"]\r\n\r\n-- \r\nCheers,\r\nHarry Brundage\n"}
        @model = parse_sendgrid(@params, true)
        @model.discussable.should == @quote
      end
      it "should find a referenced quote" do
        @params = {"headers"=>"Received: by 127.0.0.1 with SMTP id rRDnTCiqCA\n        Mon, 05 Jul 2010 18:26:35 -0700 (PDT)\nReceived: from mail-iw0-f177.google.com (unknown [10.9.180.37])\n\tby mx1.sendgrid.net (Postfix) with ESMTP id 28CC646548E\n\tfor <kevin@watch.dowling.com>; Mon,  5 Jul 2010 18:26:35 -0700 (PDT)\nReceived: by iwn40 with SMTP id 40so3158802iwn.8\n        for <kevin@watch.dowling.com>; Mon, 05 Jul 2010 18:26:34 -0700 (PDT)\nDKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;\n        d=gmail.com; s=gamma;\n        h=domainkey-signature:mime-version:received:received:date:message-id\n         :subject:from:to:content-type;\n        bh=utacxs7soi5rIybgFceFG5fP6tv2Jf4KboxiuW8Z1xE=;\n        b=agtTPTy9u7dJp4lUKOpTGL+Ji28SUGUQoQi5K7N4xOcTNHpYBvTsKQPG2LaYQLu+9R\n         g/B7rrzT3agEmqtk+0P27i2MuB7rbdDJ8WsMrLsgXLwV5klfrAmdEodfPjaw4QgioXiN\n         msYEkTde8+pVkbZdKQkXmPkTK7fRdWYScF63A=\nDomainKey-Signature: a=rsa-sha1; c=nofws;\n        d=gmail.com; s=gamma;\n        h=mime-version:date:message-id:subject:from:to:content-type;\n        b=E4WN6pprh5tsFey2JIovmLeCHKd3WddHPfhEcfE1UNSl9JzIVR5epAXnhXg/vPYn/v\n         q5F6b8O0OaJS8udeZGiZOTu8FH+w/FfpLMpvWrCTDrVHmb3qvbY4AXiL2wUc+L4hirvT\n         KY1uhSWurliMud5nrpA1m0rbYX/W6INgTyro4=\nMIME-Version: 1.0\nReceived: by 10.231.85.144 with SMTP id o16mr4237565ibl.182.1278379594815; \n\tMon, 05 Jul 2010 18:26:34 -0700 (PDT)\nReceived: by 10.231.130.102 with HTTP; Mon, 5 Jul 2010 18:26:34 -0700 (PDT)\nDate: Mon, 5 Jul 2010 21:26:34 -0400\nMessage-ID: <AANLkTilkHyFooIOT7c2Sf3U2kBzWX3g7rqRrckNT3skh@mail.gmail.com>\nSubject: Test Email from harry\nFrom: John Supplier <john123@supplier.com>\nTo: Kevin Dowling <kevin@watch.dowling.com>\nContent-Type: multipart/alternative; boundary=001485ec0de8a318f9048aadf1bb\n", "attachments"=>"0", "subject"=>"Test from harry brundage\n", "to"=>"Kevin Dowling <kevin@watch.dowling.com>\n", "html"=>"test talking about [!!"+@quote.discussion_tag+"]<br clear=\"all\"><br>-- <br>Cheers,<br>Harry Brundage<br>\n", "from"=>"John Supplier <john123@supplier.com>\n", "text"=>"test talking about [!!"+@quote.discussion_tag+"]\r\n\r\n-- \r\nCheers,\r\nHarry Brundage\n"}
        @model = parse_sendgrid(@params, true)
        @model.discussable.should == @quote
      end
    end
    
    after(:all) do
      [@supplier, @customer, @kevin, @david, @quote, @rfq].each do |i| i.destroy end
    end
  end
  
end

def parse_sendgrid(params, find = false)
  params = params.inject({}) {|acc, (k,v)| acc[k.intern] = v; acc}
  x = Correspondence.new_from_sendgrid(params)
  x.find_discussables if find
  x
end