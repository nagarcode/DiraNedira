import 'package:dira_nedira/Services/auth.dart';
import 'package:dira_nedira/Services/database.dart';
import 'package:dira_nedira/home/account/apartment.dart';
import 'package:dira_nedira/home/home_page.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:dira_nedira/sign_in/sign_in_screen.dart';
import 'package:dira_nedira/splash-screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('he', null);
    Intl.defaultLocale = 'he';
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder<User>(
      stream: auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.connectionState != ConnectionState.done) {
          User user = snapshot.data;
          if (user == null) {
            return SignInScreen.create(context);
          }
          final database = FirestoreDatabase(uid: user.uid);
          return StreamBuilder<String>(
            stream: database.apartmentIdStream(),
            builder: (context, snapshot) {
              final apartmentId = snapshot.hasData ? snapshot.data : null;
              if (snapshot.connectionState != ConnectionState.active &&
                  snapshot.connectionState != ConnectionState.done)
                return SplashScreen();
              else
                return StreamBuilder<Apartment>(
                  stream: database.apartmentStream(apartmentId),
                  builder: (context, apartmentSnapshot) {
                    final apartment =
                        apartmentSnapshot.hasData && apartmentId != null
                            ? apartmentSnapshot.data
                            : null;
                    if (apartmentSnapshot.connectionState !=
                            ConnectionState.active &&
                        apartmentSnapshot.connectionState !=
                            ConnectionState.done)
                      return SplashScreen();
                    else
                      return StreamBuilder<List<User>>(
                        stream: database.singleDocUserStream(apartmentId),
                        builder: (context, usersSnapshot) {
                          final usersList =
                              usersSnapshot.hasData && apartmentId != null
                                  ? usersSnapshot.data
                                  : null;
                          if (usersSnapshot.connectionState !=
                                  ConnectionState.active &&
                              usersSnapshot.connectionState !=
                                  ConnectionState.done) return SplashScreen();
                          return StreamBuilder<List<Investment>>(
                            stream: apartment == null
                                ? Stream.empty()
                                :
                                // database.investmentsStream(
                                //     apartment.id, currentMonthYear),
                                database
                                    .singleDocInvestmentsStream(apartmentId),
                            builder: (context, investmentsSnapshot) {
                              final allInvestments = investmentsSnapshot.hasData
                                  ? investmentsSnapshot.data
                                  : null;
                              if (investmentsSnapshot.connectionState !=
                                      ConnectionState.active &&
                                  investmentsSnapshot.connectionState !=
                                      ConnectionState.done)
                                return SplashScreen();
                              return Provider<Apartment>.value(
                                value: apartment,
                                child: Provider<List<Investment>>.value(
                                  // updateShouldNotify: (previous, next) => true,
                                  value: allInvestments,
                                  child: Provider<List<User>>.value(
                                    value: usersList,
                                    child: Provider<User>.value(
                                      // doesnt need a builder because i just want to provide the user value
                                      value: user,
                                      child: Provider<Database>(
                                        create: (_) => database,
                                        child: HomePage(database, apartmentId),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                  },
                );
            },
          );
        } else {
          return SplashScreen();
        }
      },
    );
  }
}
