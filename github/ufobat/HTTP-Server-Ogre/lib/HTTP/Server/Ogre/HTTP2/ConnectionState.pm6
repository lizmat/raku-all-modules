use v6;

class HTTP::Server::Ogre::HTTP2::ConnectionState {
    has Supplier $.settings = Supplier::Preserving.new;
    has Supplier $.ping     = Supplier::Preserving.new;
}
