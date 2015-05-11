package ua.edu.sumdu.essuir.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import ua.edu.sumdu.essuir.YearStatistics;
import ua.edu.sumdu.essuir.entity.GeneralStatistics;
import ua.edu.sumdu.essuir.repository.GeneralStatisticsRepository;
import java.util.ArrayList;
import java.util.List;

@Service
public class GeneralStatisticsService {

    private List<YearStatistics> cacheListYearsStatistics;

    @Autowired
    private GeneralStatisticsRepository generalStatisticsRepository;

    public  List<YearStatistics> getListYearsStatistics(){
        if(cacheListYearsStatistics == null) {
            updateListYearsStatistics();
        }
        return cacheListYearsStatistics;
    }

    public void updateListYearsStatistics(){
        List<YearStatistics> listYearsStatistics = new ArrayList<YearStatistics>();
        List<GeneralStatistics> tmpYearsStatistics = (ArrayList<GeneralStatistics>) generalStatisticsRepository.findAllYearsStatistics();
        for (GeneralStatistics entity : tmpYearsStatistics) {
            YearStatistics yearStatistics = new YearStatistics();
            yearStatistics.setYear(entity.getYear());
            yearStatistics.setTotalYearViews(entity.getViewsCount());
            yearStatistics.setTotalYearDownloads(entity.getDownloadsCount());
            ArrayList<Integer> tmpYearViews = (ArrayList<Integer>) generalStatisticsRepository.findAllMonthsViewsStatisticsByYear(entity.getYear());
            ArrayList<Integer> tmpYearDownloads = (ArrayList<Integer>) generalStatisticsRepository.findAllMonthsDownloadsStatisticsByYear(entity.getYear());
            if(tmpYearViews.size() < 12){
                yearStatistics.setCurrentMonth(tmpYearViews.size());
                for (int i = tmpYearViews.size(); i < 12; i++) {
                    tmpYearViews.add(0);
                    tmpYearDownloads.add(0);
                }
            }
            yearStatistics.setYearViews(tmpYearViews);
            yearStatistics.setYearDownloads(tmpYearDownloads);
            listYearsStatistics.add(yearStatistics);
        }
        cacheListYearsStatistics = listYearsStatistics;
    }

}
