import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../main.dart';
import '../model/all.dart';

enum SearchEngine { google, duckDuckGo, bing, yahoo }

class MirrorScreen extends StatefulWidget {
  const MirrorScreen({super.key});

  @override
  State<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends State<MirrorScreen> {
  late InAppWebViewController _webViewController;
  late TextEditingController _searchController = TextEditingController();
  SearchEngine selectedSearchEngine = SearchEngine.google;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  Future<void> _loadWebPage(String currentUrl, BuildContext context) async {
    final bool isConnected = await Provider.of<BrowserModel>(context, listen: false).checkInternetConnection();
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection.'),
        ),
      );
      return;
    }

    _webViewController.loadUrl(
      urlRequest: URLRequest(
        url: Uri.parse(currentUrl),
      ),
    );
  }

  void _search(SearchEngine engine, String query) {
    String baseUrl;

    switch (engine) {
      case SearchEngine.google:
        baseUrl = 'https://www.google.com/search?q=';
        break;
      case SearchEngine.duckDuckGo:
        baseUrl = 'https://duckduckgo.com/?q=';
        break;
      case SearchEngine.bing:
        baseUrl = 'https://www.bing.com/search?q=';
        break;
      case SearchEngine.yahoo:
        baseUrl = 'https://search.yahoo.com/search?p=';
        break;
    }

    final url = '$baseUrl$query';

    if (query.isNotEmpty) {
      _webViewController.loadUrl(
        urlRequest: URLRequest(
          url: Uri.parse(url),
        ),
      );
    }
  }

  void _goHome(String currentUrl) {
    _webViewController.loadUrl(
      urlRequest: URLRequest(
        url: Uri.parse(currentUrl),
      ),
    );
  }

  void _addBookmark(BuildContext context) {
    final currentUrl = Provider.of<BrowserModel>(context, listen: false).currentUrl;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Bookmark',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: TextEditingController(text: currentUrl),
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Bookmark URL',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  final url = currentUrl;
                  Provider.of<BrowserModel>(context, listen: false).addBookmark(url);
                  saveBookmarks(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bookmark added for $url'),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Add Bookmark'),
              ),
            ],
          ),
        );
      },
    );
  }

  void saveBookmarks(BuildContext context) {
    final bookmarks = Provider.of<BrowserModel>(context, listen: false).bookmarks;
    final savedBookmarks = pref.getStringList('bookmarks') ?? [];
    savedBookmarks.addAll(bookmarks);
    pref.setStringList('bookmarks', savedBookmarks);
  }

  void _showAllBookmarks(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Bookmarks',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Consumer<BrowserModel>(
                  builder: (context, browserModel, child) {
                    final bookmarks = browserModel.bookmarks;
                    return ListView.builder(
                      itemCount: bookmarks.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(bookmarks[index]),
                          trailing: IconButton(
                            onPressed: () {
                              Provider.of<BrowserModel>(context, listen: false).removeBookmark(index);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Browser",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'option1',
                  child: const Text('All Bookmark'),
                  onTap: () {
                    _showAllBookmarks(context);
                  },
                ),
                PopupMenuItem<String>(
                  value: 'option2',
                  child: const Text('Search Engine'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Search Engine"),
                          content: SizedBox(
                            height: 300,
                            width: 250,
                            child: Column(
                              children: [
                                ListTile(
                                  title: const Text("Google"),
                                  leading: const CircleAvatar(backgroundImage: AssetImage("assets/google.png")),
                                  trailing: Radio(
                                    value: SearchEngine.google,
                                    groupValue: selectedSearchEngine,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSearchEngine =
                                        value as SearchEngine;
                                      });
                                    },
                                  ),
                                ),
                                ListTile(
                                  title: const Text("DuckDuckGo"),
                                  leading: const CircleAvatar(
                                      backgroundImage:
                                      AssetImage("assets/duck.png")),
                                  trailing: Radio(
                                    value: SearchEngine.duckDuckGo,
                                    groupValue: selectedSearchEngine,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSearchEngine =
                                        value as SearchEngine;
                                      });
                                    },
                                  ),
                                ),
                                ListTile(
                                  title: const Text("Bing"),
                                  leading: const CircleAvatar(
                                      backgroundImage:
                                      AssetImage("assets/bing.jpg")),
                                  trailing: Radio(
                                    value: SearchEngine.bing,
                                    groupValue: selectedSearchEngine,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSearchEngine =
                                        value as SearchEngine;
                                      });
                                    },
                                  ),
                                ),
                                ListTile(
                                  title: const Text("Yahoo"),
                                  leading: const CircleAvatar(
                                      backgroundImage:
                                      AssetImage("assets/yaho.png")),
                                  trailing: Radio(
                                    value: SearchEngine.yahoo,
                                    groupValue: selectedSearchEngine,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSearchEngine =
                                        value as SearchEngine;
                                      });
                                    },
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _search(
                                        selectedSearchEngine,
                                        _searchController
                                            .text);
                                  },
                                  child: const Text('Search'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (query) {
                _search(selectedSearchEngine, query);
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Search",
                suffixIcon: IconButton(
                  onPressed: () {
                    _search(selectedSearchEngine, _searchController.text);
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<ConnectivityResult>(
                stream: Connectivity().onConnectivityChanged,
                builder: (context, snapshot) {
                  final connectivityResult = snapshot.data;
                  if (connectivityResult == ConnectivityResult.none) {
                    return const Center(child: Text("No Internet"));
                  } else {
                    return InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: Uri.parse(
                            Provider.of<BrowserModel>(context).currentUrl),
                      ),
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                      },
                      onLoadStop: (controller, url) {
                        Provider.of<BrowserModel>(context, listen: false)
                            .updateUrl(url.toString());
                      },
                    );
                  }
                }),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_add_outlined, color: Colors.black),
            label: "Bookmark",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                _webViewController.goBack();
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            ),
            label: "Back",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                _webViewController.reload();
              },
              icon: const Icon(Icons.restart_alt_rounded, color: Colors.black),
            ),
            label: "Refresh",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                _webViewController.goForward();
              },
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            ),
            label: "Forward",
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            _goHome(
                Provider.of<BrowserModel>(context, listen: false).currentUrl);
          } else if (index == 1) {
            _addBookmark(context);
          }
        },
      ),
    );
  }
}
