import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../constant.dart';
import '../widgets/app_text.dart.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the start and end of the range of page numbers to display
    int startPage = (currentPage - 1) ~/ 3 * 3 + 1;
    int endPage = startPage + 2;
    if (endPage > totalPages) endPage = totalPages;

    return Container(
      width: 15.w,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: const Center(child: Icon(Icons.arrow_back_ios, size: 12)),
            ),
          ),
          const SizedBox(width: 8),  // Space between arrow and page numbers
          Row(
            children: List.generate((endPage - startPage + 1), (index) {
              int pageNumber = startPage + index;
              return GestureDetector(
                onTap: () => onPageChanged(pageNumber),
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  //padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: currentPage == pageNumber
                        ? primaryColor  // Highlight the current page
                        : Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: AppTextWidget(
                    text: '$pageNumber',
                    fontSize: 12,
                    color: currentPage == pageNumber
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 8),  // Space between page numbers and next arrow
          GestureDetector(
            onTap: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: const Center(child: Icon(Icons.arrow_forward_ios, size: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
