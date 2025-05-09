import 'package:flutter/material.dart';
import 'package:kos29/app/data/models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onHide;
  final VoidCallback onShow;
  final VoidCallback onRespond;

  const ReviewCard({
    super.key,
    required this.review,
    required this.onHide,
    required this.onShow,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: review.hidden ? Colors.grey[200] : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'⭐' * review.rating.toInt()} (${review.rating})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            if (review.ownerResponse != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Balasan: ${review.ownerResponse!}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.green,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!review.hidden)
                  TextButton.icon(
                    icon: const Icon(Icons.visibility_off),
                    onPressed: onHide,
                    label: const Text('Sembunyikan'),
                  ),
                if (review.hidden)
                  TextButton.icon(
                    icon: const Icon(Icons.visibility),
                    onPressed: onShow,
                    label: const Text('Tampilkan'),
                  ),
                TextButton.icon(
                  icon: const Icon(Icons.reply),
                  onPressed: onRespond,
                  label: const Text('Balas'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
