# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TrackHelper do

  include TrackHelper
  include LinkToHelper

  describe '#unsubscribe_notice' do

    it 'requires a track_type' do
      expect { unsubscribe_notice }.to raise_error(ArgumentError)
    end

    context 'with a search track' do
      let(:track_thing) { FactoryGirl.build(:search_track) }

      it 'creates an unsubscribe notice' do
        search_url =
          search_path([track_thing.track_query, 'newest', 'advanced'])
        data = { :track_type => track_thing.track_type,
                 :search_url => search_url }

        expected = 'You are no longer following <a href="/search/' \
                   'Example%20Query/newest/advanced">this search</a>.'

        expect(unsubscribe_notice(data)).to eq(expected)
      end

      it 'requires a :track_type key' do
        expect { unsubscribe_notice({}) }.to raise_error(KeyError)
      end

      it 'requires a :search_url key' do
        expect { unsubscribe_notice(:track_type => 'search_query') }.
          to raise_error(KeyError)
      end

    end

    context 'with a user track' do
      let(:track_thing) { FactoryGirl.build(:user_track) }

      it 'creates an unsubscribe notice' do
        link_to_user = user_link(track_thing.tracked_user)
        data = { :track_type => track_thing.track_type,
                 :link_to_user => link_to_user }

        expected = "You are no longer following '#{ link_to_user }', a person."

        expect(unsubscribe_notice(data)).to eq(expected)
      end

      it 'requires a :track_type key' do
        expect { unsubscribe_notice({}) }.to raise_error(KeyError)
      end

      it 'requires a :link_to_user key' do
        expect { unsubscribe_notice(:track_type => 'user_updates') }.
          to raise_error(KeyError)
      end

    end

    context 'with a public body track' do
      let(:track_thing) { FactoryGirl.build(:public_body_track) }

      it 'creates an unsubscribe notice' do
        link_to_authority = public_body_link(track_thing.public_body)
        data = { :track_type => track_thing.track_type,
                 :link_to_authority => link_to_authority }

        expected = "You are no longer following '#{ link_to_authority }', a " \
                   "public authority."

        expect(unsubscribe_notice(data)).to eq(expected)
      end

      it 'requires a :track_type key' do
        expect { unsubscribe_notice({}) }.to raise_error(KeyError)
      end

      it 'requires a :link_to_authority key' do
        expect { unsubscribe_notice(:track_type => 'public_body_updates') }.
          to raise_error(KeyError)
      end

    end

    context 'with a successful request track' do
      let(:track_thing) { FactoryGirl.build(:successful_request_track) }

      it 'creates an unsubscribe notice' do
        expected = 'You are no longer following <a href="/list/successful">' \
                   'successful requests</a>.'
        expect(unsubscribe_notice(track_thing)).to eq(expected)
      end

      it 'creates an unsubscribe notice' do
        data = { :track_type => track_thing.track_type }

        expected = "You are no longer following '#{ link_to_authority }', a " \
                   "public authority."

        expect(unsubscribe_notice(data)).to eq(expected)
      end
    end

    context 'with a new request track' do
      let(:track_thing) { FactoryGirl.build(:new_request_track) }

      it 'creates an unsubscribe notice' do
        expected = 'You are no longer following ' \
                   '<a href="/list">new requests</a>.'
        expect(unsubscribe_notice(track_thing)).to eq(expected)
      end

    end

    context 'with a request update track' do
      let(:track_thing) { FactoryGirl.build(:request_update_track) }

      it 'creates an unsubscribe notice' do
        expected = "You are no longer following " \
                   "'#{ request_link(track_thing.info_request) }', a request."
        expect(unsubscribe_notice(track_thing)).to eq(expected)
      end

    end

  end

  describe 'when displaying notices for a search track' do

    before do
      @track_thing = FactoryGirl.build(:search_track)
    end

    it 'should create an already subscribed_notice' do
      expected = %Q(You are already subscribed to <a href="/search/Example%20Query/newest/advanced">this search</a>.)
      expect(already_subscribed_notice(@track_thing)).to eq(expected)
    end

    it 'should create an email subscription notice' do
      expected = %Q(You will now be emailed updates about <a href="/search/Example%20Query/newest/advanced">this search</a>.)
      expect(subscribe_email_notice(@track_thing)).to eq(expected)
    end

    it 'should create a following subscription notice' do
      expected = %Q(You are now <a href="#{show_user_wall_path(:url_name => @track_thing.tracking_user.url_name)}">following</a> updates about <a href="/search/Example%20Query/newest/advanced">this search</a>.)
      expect(subscribe_follow_notice(@track_thing)).to eq(expected)
    end

    it 'should create a description of the track' do
      expected = %Q(<a href="/search/Example%20Query/newest/advanced">anything matching text 'Example Query'</a>)
      expect(track_description(@track_thing)).to eq(expected)
    end

  end

  describe 'when displaying notices for a user track' do

    before do
      @track_thing = FactoryGirl.build(:user_track)
    end

    it 'should create an already subscribed_notice' do
      expected = %Q(You are already subscribed to '#{user_link(@track_thing.tracked_user)}', a person.)
      expect(already_subscribed_notice(@track_thing)).to eq(expected)
    end

    it 'should create an email subscription notice' do
      expected = %Q(You will now be emailed updates about '#{user_link(@track_thing.tracked_user)}', a person.)
      expect(subscribe_email_notice(@track_thing)).to eq(expected)
    end

    it 'should create a following subscription notice' do
      expected = %Q(You are now <a href="#{show_user_wall_path(:url_name => @track_thing.tracking_user.url_name)}">following</a> updates about '#{user_link(@track_thing.tracked_user)}', a person.)
      expect(subscribe_follow_notice(@track_thing)).to eq(expected)
    end

    it 'should create a description of the track' do
      expected = %Q('#{user_link(@track_thing.tracked_user)}', a person)
      expect(track_description(@track_thing)).to eq(expected)
    end

  end

  describe 'when displaying notices for a public body track' do

    before do
      @track_thing = FactoryGirl.build(:public_body_track)
    end

    it 'should create an already subscribed_notice' do
      expected = %Q(You are already subscribed to '#{public_body_link(@track_thing.public_body)}', a public authority.)
      expect(already_subscribed_notice(@track_thing)).to eq(expected)
    end

    it 'should create an email subscription notice' do
      expected = %Q(You will now be emailed updates about '#{public_body_link(@track_thing.public_body)}', a public authority.)
      expect(subscribe_email_notice(@track_thing)).to eq(expected)
    end

    it 'should create a following subscription notice' do
      expected = %Q(You are now <a href="#{show_user_wall_path(:url_name => @track_thing.tracking_user.url_name)}">following</a> updates about '#{public_body_link(@track_thing.public_body)}', a public authority.)
      expect(subscribe_follow_notice(@track_thing)).to eq(expected)
    end

    it 'should create a description of the track' do
      expected = %Q('#{public_body_link(@track_thing.public_body)}', a public authority)
      expect(track_description(@track_thing)).to eq(expected)
    end
  end

  describe 'when displaying notices for a successful request track' do

    before do
      @track_thing = FactoryGirl.build(:successful_request_track)
    end

    it 'should create an already subscribed_notice' do
      expected = %Q(You are already subscribed to any <a href="/list/successful">successful requests</a>.)
      expect(already_subscribed_notice(@track_thing)).to eq(expected)
    end

    it 'should create an email subscription notice' do
      expected = %Q(You will now be emailed updates about <a href="/list/successful">successful requests</a>.)
      expect(subscribe_email_notice(@track_thing)).to eq(expected)
    end

    it 'should create a following subscription notice' do
      expected = %Q(You are now <a href="#{show_user_wall_path(:url_name => @track_thing.tracking_user.url_name)}">following</a> updates about <a href="/list/successful">successful requests</a>.)
      expect(subscribe_follow_notice(@track_thing)).to eq(expected)
    end

    it 'should create a description of the track' do
      expected = %Q(<a href="/list/successful">successful requests</a>)
      expect(track_description(@track_thing)).to eq(expected)
    end
  end

  describe 'when displaying notices for a new request track' do

    before do
      @track_thing = FactoryGirl.build(:new_request_track)
    end

    it 'should create an already subscribed_notice' do
      expected = %Q(You are already subscribed to any <a href="/list">new requests</a>.)
      expect(already_subscribed_notice(@track_thing)).to eq(expected)
    end

    it 'should create an email subscription notice' do
      expected = %Q(You will now be emailed updates about any <a href="/list">new requests</a>.)
      expect(subscribe_email_notice(@track_thing)).to eq(expected)
    end

    it 'should create a following subscription notice' do
      expected = %Q(You are now <a href="#{show_user_wall_path(:url_name => @track_thing.tracking_user.url_name)}">following</a> updates about <a href="/list">new requests</a>.)
      expect(subscribe_follow_notice(@track_thing)).to eq(expected)
    end

    it 'should create a description of the track' do
      expected = %Q(<a href="/list">new requests</a>)
      expect(track_description(@track_thing)).to eq(expected)
    end

  end

  describe 'when displaying notices for a request update track' do

    before do
      @track_thing = FactoryGirl.build(:request_update_track)
    end

    it 'should create an already subscribed_notice' do
      expected = %Q(You are already subscribed to '#{request_link(@track_thing.info_request)}', a request.)
      expect(already_subscribed_notice(@track_thing)).to eq(expected)
    end

    it 'should create an email subscription notice' do
      expected = %Q(You will now be emailed updates about '#{request_link(@track_thing.info_request)}', a request.)
      expect(subscribe_email_notice(@track_thing)).to eq(expected)
    end

    it 'should create a following subscription notice' do
      expected = %Q(You are now <a href="#{show_user_wall_path(:url_name => @track_thing.tracking_user.url_name)}">following</a> updates about '#{request_link(@track_thing.info_request)}', a request.)
      expect(subscribe_follow_notice(@track_thing)).to eq(expected)
    end

    it 'should create a description of the track' do
      expected = %Q('#{request_link(@track_thing.info_request)}', a request)
      expect(track_description(@track_thing)).to eq(expected)
    end

  end

end
