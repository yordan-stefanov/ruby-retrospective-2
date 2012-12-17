describe "Collection" do
  let(:collection) { Collection.parse(SONGS) }

  it "can find all the artists in the collection" do
    collection.artists.should =~ [
      'Sting',
      'Eva Cassidy',
      'Bill Evans',
      'John Coltrane',
      'Pearl Jam',
      'Norah Johnes',
      'Thelonious Monk',
    ]
  end

  it "can find all the names of all songs in the collection" do
    collection.names.should =~ [
      'Fields of Gold',
      'Mad About You',
      'Autumn Leaves',
      'Brain of J.F.K',
      'Jeremy',
      'Come Away With Me',
      'Acknowledgment',
      'Ruby, My Dear'
    ]
  end

  it "can find all the albums in the collection" do
    collection.albums.should =~ [
      "Ten Summoner's Tales",
      'The Soul Cages',
      'Live at Blues Alley',
      'Portrait in Jazz',
      'Yield',
      'Ten',
      'One',
      'A Love Supreme',
      'Mysterioso',
    ]
  end

  it "can be filtered by song name" do
    filtered = collection.filter Criteria.name('Fields of Gold')
    filtered.map(&:artist).should =~ ['Eva Cassidy', 'Sting']
  end

  it "can be filtered by song name" do
    filtered = collection.filter Criteria.artist('Sting')
    filtered.map(&:album).should =~ ['The Soul Cages', "Ten Summoner's Tales"]
  end

  it "can be filtered by album" do
    filtered = collection.filter Criteria.album('Live at Blues Alley')
    filtered.map(&:name).should =~ ['Fields of Gold', 'Autumn Leaves']
  end

  it "can return an empty result" do
    filtered = collection.filter Criteria.album('The Dark Side of the Moon')
    filtered.to_a.should eq []
  end

  it "supports a conjuction of filters" do
    filtered = collection.filter Criteria.artist('Sting') & Criteria.name('Fields of Gold')
    filtered.map(&:album).should eq ["Ten Summoner's Tales"]
  end

  it "supports a disjunction of filters" do
    filtered = collection.filter Criteria.artist('Sting') | Criteria.name('Fields of Gold')
    filtered.map(&:album).should =~ [
      "Ten Summoner's Tales",
      'Live at Blues Alley',
      'The Soul Cages',
    ]
  end

  it "supports negation of filters" do
    filtered = collection.filter Criteria.artist('Sting') & !Criteria.name('Fields of Gold')
    filtered.map(&:name).should eq ['Mad About You']
  end

  it "can be adjoined with another collection" do
    sting    = collection.filter Criteria.artist('Sting')
    eva      = collection.filter Criteria.artist('Eva Cassidy')
    adjoined = sting.adjoin(eva)

    adjoined.count.should eq 4
    adjoined.names.should =~ [
      'Fields of Gold',
      'Autumn Leaves',
      'Mad About You',
    ]
  end

  it "does not mutate when filtered"
  it "does not mutate when adjoined"

  SONGS = <<END
Fields of Gold
Sting
Ten Summoner's Tales

Mad About You
Sting
The Soul Cages

Fields of Gold
Eva Cassidy
Live at Blues Alley

Autumn Leaves
Eva Cassidy
Live at Blues Alley

Autumn Leaves
Bill Evans
Portrait in Jazz

Brain of J.F.K
Pearl Jam
Yield

Jeremy
Pearl Jam
Ten

Come Away With Me
Norah Johnes
One

Acknowledgment
John Coltrane
A Love Supreme

Ruby, My Dear
Thelonious Monk
Mysterioso
END
end
