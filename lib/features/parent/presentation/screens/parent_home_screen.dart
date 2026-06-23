import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/logic/home_cubit/home_cubit.dart';
import 'package:kids_transport/features/parent/logic/home_cubit/home_state.dart';
import '../widgets/state_widgets/new_user_widget.dart';
import '../widgets/state_widgets/has_kids_widget.dart';
import '../widgets/state_widgets/pending_req_widget.dart';
import '../widgets/state_widgets/active_trip_widget.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParentHomeCubit()..fetchParentHomeData(3), // 🌟 غيري الرقم هنا (1، 2، 3، 4) لتجربة كل الحالات في النسخة التجريبية
      child: Scaffold(
        body: BlocBuilder<ParentHomeCubit, ParentHomeState>(
          builder: (context, state) {
            if (state is ParentHomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ParentNewUserMode) {
              return const NewUserWidget();
            } else if (state is ParentHasKidsNoSubscription) {
              return HasKidsWidget(kids: state.kids);
            } else if (state is ParentPendingRequestsMode) {
              return PendingReqWidget(requests: state.pendingRequests);
            } else if (state is ParentActiveTripMode) {
              return ActiveTripWidget(todayTrips: state.todayTrips, activeTrip: state.activeTrip);
            } else if (state is ParentHomeError) {
              return Center(child: Text(state.errorMessage, style: const TextStyle(color: Colors.red)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}