//
//  search_overlay.dart
//

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'empty_search_results_view.dart';
import 'search_bar.dart';
import 'search_result_row.dart';
import 'search_state.dart';
import 'search_cubit.dart';

/// Sits on top of whatever screen hosts it: a bottom search field that dims
/// the content behind it and reveals live results while it is active.
class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  late final SearchCubit _cubit = GetIt.instance<SearchCubit>();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = _cubit.state.searchQuery;
    _controller.addListener(_onQueryChanged);
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() => _cubit.updateSearchQuery(_controller.text);

  void _clear() {
    _controller.clear();
    _cubit.updateSearchQuery('');
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: _cubit,
      builder: (context, state) {
        final isActive = _focusNode.hasFocus || state.searchQuery.isNotEmpty;

        // Both slots are always present and keyed: if the children shifted as
        // the overlay activated, the field's element would be rebuilt and the
        // keyboard connection lost mid-typing.
        return Stack(
          children: [
            Positioned.fill(
              key: const ValueKey('search-dimming'),
              child: isActive ? _dimming(state) : const SizedBox.shrink(),
            ),
            Positioned.fill(
              key: const ValueKey('search-content'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Always present, so the field below keeps its identity when
                  // the overlay becomes active and does not lose focus.
                  Expanded(
                    child: isActive
                        ? _searchResults(state)
                        : const SizedBox.expand(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: MovieSearchBar(
                      controller: _controller,
                      focusNode: _focusNode,
                      onClear: _clear,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dimming(SearchState state) {
    return GestureDetector(
      onTap: _focusNode.unfocus,
      child: ColoredBox(
        color: Colors.black.withValues(
          alpha: state.searchResults.isEmpty ? 0.8 : 1,
        ),
      ),
    );
  }

  Widget _searchResults(SearchState state) {
    if (state.showEmptyLabel) {
      return Center(child: EmptySearchResultsView(query: state.searchQuery));
    }
    if (state.searchQuery.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(child: _resultsList(state)),
        if (state.isSearching)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _resultsList(SearchState state) {
    return Semantics(
      identifier: 'searchResults',
      explicitChildNodes: true,
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: state.searchResults.length,
        itemBuilder: (context, index) {
          final movie = state.searchResults[index];
          return GestureDetector(
            onTap: () {
              _cubit.showDetails(movieId: movie.id);
              _focusNode.unfocus();
            },
            child: SearchResultRow(movie: movie),
          );
        },
      ),
    );
  }
}
